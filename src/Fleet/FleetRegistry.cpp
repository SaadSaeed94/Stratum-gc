#include "FleetRegistry.h"
#include "QmlObjectListModel.h"
#include "MAVLinkLib.h"

#include <QDebug>
#include <QSettings>
#include <QTimer>
#include <QtMath>

// ─────────────────────────────────────────────────────────────────────────────
//  Singleton
// ─────────────────────────────────────────────────────────────────────────────

FleetRegistry* FleetRegistry::instance()
{
    static FleetRegistry* _instance = nullptr;
    if (!_instance) {
        _instance = new FleetRegistry();
    }
    return _instance;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Construction
// ─────────────────────────────────────────────────────────────────────────────

FleetRegistry::FleetRegistry(QObject* parent)
    : QObject(parent)
    , _enrolledList(new QmlObjectListModel(this))
{
    loadRoleMap();
    loadSession();
}

// ─────────────────────────────────────────────────────────────────────────────
//  preEnroll — called by FleetConfigLoader from fleet.json before heartbeat
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::preEnroll(uint8_t sysid, const QString& vehicleId,
                               const QString& role, uint8_t mavType)
{
    if (_enrolledBySysid.contains(sysid)) {
        qDebug() << "[FleetRegistry] preEnroll: sysid" << sysid << "already enrolled";
        return;
    }

    // Prevent duplicate vehicleId entries
    for (auto* ev : _enrolledBySysid) {
        if (ev->vehicleId() == vehicleId) {
            qDebug() << "[FleetRegistry] preEnroll: vehicleId" << vehicleId << "already exists";
            return;
        }
    }

    const QString typeStr = typeStringFromMAVType(mavType);
    auto* ev = new EnrolledVehicle(sysid, mavType, vehicleId, typeStr, role, this);
    ev->setLinkState(EnrolledVehicle::Offline);

    _enrolledBySysid[sysid] = ev;
    _enrolledList->append(ev);

    emit vehicleEnrolled(sysid);
    emit enrolledVehiclesChanged();

    qDebug() << "[FleetRegistry] Pre-enrolled:" << vehicleId
             << "sysid:" << sysid << "role:" << role;
}

// ─────────────────────────────────────────────────────────────────────────────
//  processHeartbeat — called from MAVLinkProtocol for every HEARTBEAT
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::processHeartbeat(uint8_t sysid, uint8_t mavType, uint8_t autopilot)
{
    Q_UNUSED(autopilot)

    if (sysid == 255 || sysid == 0) return;

    if (!_enrolledBySysid.contains(sysid)) {
        // Try to promote a sysid=0 placeholder from fleet.json
        // matching by mavType as best-effort
        EnrolledVehicle* placeholder = nullptr;
        for (auto it = _enrolledBySysid.begin(); it != _enrolledBySysid.end(); ++it) {
            if (it.key() == 0) {
                placeholder = it.value();
                _enrolledBySysid.erase(it);
                break;
            }
        }

        if (placeholder) {
            _enrolledBySysid[sysid] = placeholder;
            qDebug() << "[FleetRegistry] Promoted pre-enrolled"
                     << placeholder->vehicleId() << "to sysid" << sysid;
        } else {
            // Brand new vehicle not in fleet.json
            const QString typeStr = typeStringFromMAVType(mavType);
            const QString role    = roleFromMAVType(mavType);
            const QString id      = QStringLiteral("Vehicle-%1").arg(sysid);

            auto* ev = new EnrolledVehicle(sysid, mavType, id, typeStr, role, this);
            _enrolledBySysid[sysid] = ev;
            _enrolledList->append(ev);

            emit vehicleEnrolled(sysid);
            emit enrolledVehiclesChanged();

            qDebug() << "[FleetRegistry] New vehicle from heartbeat:"
                     << id << "sysid:" << sysid;

            QTimer::singleShot(CAMERA_REQUEST_DELAY_MS, this, [this, sysid]() {
                requestCameraInformation(sysid);
            });

        }
    }

    auto* ev = _enrolledBySysid[sysid];
    const bool wasOffline = (ev->linkState() != EnrolledVehicle::Online);
    ev->updateHeartbeat();

    if (wasOffline) {
        emit vehicleLinkRecovered(sysid);
        qDebug() << "[FleetRegistry] sysid" << sysid << "link recovered";
    }

    // Reset heartbeat watchdog
    QTimer* timer = _heartbeatTimers.value(sysid, nullptr);
    if (!timer) {
        timer = new QTimer(this);
        timer->setSingleShot(true);
        connect(timer, &QTimer::timeout, this, [this, sysid]() {
            onHeartbeatTimeout(sysid);
        });
        _heartbeatTimers[sysid] = timer;
    }
    timer->start(HEARTBEAT_TIMEOUT_MS);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Heartbeat timeout
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::onHeartbeatTimeout(uint8_t sysid)
{
    if (!_enrolledBySysid.contains(sysid)) return;

    auto* ev = _enrolledBySysid[sysid];

    if (ev->linkState() == EnrolledVehicle::Online) {
        ev->setLinkState(EnrolledVehicle::LinkLost);
        emit vehicleLinkLost(sysid);
        qDebug() << "[FleetRegistry] Link lost for sysid" << sysid;

        QTimer::singleShot(HEARTBEAT_TIMEOUT_MS, this, [this, sysid]() {
            if (_enrolledBySysid.contains(sysid) &&
                _enrolledBySysid[sysid]->linkState() == EnrolledVehicle::LinkLost)
            {
                _enrolledBySysid[sysid]->setLinkState(EnrolledVehicle::Offline);
                qDebug() << "[FleetRegistry] Vehicle offline: sysid" << sysid;
            }
        });
    }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Camera information
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::processCameraInformation(const mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_CAMERA_INFORMATION) return;

    const uint8_t sysid = message.sysid;
    if (!_enrolledBySysid.contains(sysid)) return;

    mavlink_camera_information_t raw;
    mavlink_msg_camera_information_decode(&message, &raw);

    CameraInfo cam;
    cam.focalLength  = raw.focal_length;
    cam.sensorWidth  = raw.sensor_size_h;
    cam.sensorHeight = raw.sensor_size_v;
    cam.modelName    = QString::fromUtf8(
                           reinterpret_cast<const char*>(raw.model_name),
                           sizeof(raw.model_name)).trimmed();

    if (raw.focal_length > 0.0f) {
        cam.hfov = 2.0f * static_cast<float>(
            qRadiansToDegrees(atan(raw.sensor_size_h / (2.0f * raw.focal_length))));
        cam.vfov = 2.0f * static_cast<float>(
            qRadiansToDegrees(atan(raw.sensor_size_v / (2.0f * raw.focal_length))));
    }
    cam.valid = true;

    _enrolledBySysid[sysid]->setCameraInfo(cam);
    emit cameraInfoReceived(sysid);

    qDebug() << "[FleetRegistry] Camera info for sysid" << sysid
             << cam.modelName << "hfov:" << cam.hfov;
}

void FleetRegistry::requestCameraInformation(uint8_t sysid)
{
    qDebug() << "[FleetRegistry] TODO: request CAMERA_INFORMATION from sysid" << sysid;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Role management
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::setRoleForType(int mavType, const QString& role)
{
    _roleMap[static_cast<uint8_t>(mavType)] = role;
    saveRoleMap();

    for (auto* ev : _enrolledBySysid) {
        if (ev->mavType() == mavType) {
            ev->setRole(role);
        }
    }

    emit roleMapChanged();
}

QString FleetRegistry::roleForType(int mavType) const
{
    const uint8_t key = static_cast<uint8_t>(mavType);
    if (_roleMap.contains(key)) {
        return _roleMap[key];
    }
    return roleFromMAVType(key);
}

QString FleetRegistry::roleFromMAVType(uint8_t mavType) const
{
    switch (mavType) {
        case 1:  return QStringLiteral("Strike");
        case 2:  return QStringLiteral("ISR");
        case 10: return QStringLiteral("Scout");
        case 13: return QStringLiteral("Strike");
        case 19:
        case 20:
        case 21: return QStringLiteral("Strike");
        default: return QStringLiteral("ISR");
    }
}

QString FleetRegistry::typeStringFromMAVType(uint8_t mavType) const
{
    switch (mavType) {
        case 1:  return QStringLiteral("Fixed Wing");
        case 2:  return QStringLiteral("Quadrotor");
        case 10: return QStringLiteral("Ground Rover");
        case 13: return QStringLiteral("Helicopter");
        case 19:
        case 20:
        case 21: return QStringLiteral("VTOL");
        default: return QStringLiteral("Unknown");
    }
}

QVariantMap FleetRegistry::roleMap() const
{
    QVariantMap out;
    for (auto it = _roleMap.cbegin(); it != _roleMap.cend(); ++it) {
        out[QString::number(it.key())] = it.value();
    }
    return out;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Vehicle queries / removal
// ─────────────────────────────────────────────────────────────────────────────

EnrolledVehicle* FleetRegistry::vehicleForSysid(int sysid) const
{
    return _enrolledBySysid.value(static_cast<uint8_t>(sysid), nullptr);
}

void FleetRegistry::removeVehicle(int sysid)
{
    const uint8_t key = static_cast<uint8_t>(sysid);
    if (!_enrolledBySysid.contains(key)) return;

    auto* ev = _enrolledBySysid.take(key);
    _enrolledList->removeOne(ev);
    ev->deleteLater();

    if (_heartbeatTimers.contains(key)) {
        _heartbeatTimers.take(key)->deleteLater();
    }

    emit enrolledVehiclesChanged();
    saveSession();

    qDebug() << "[FleetRegistry] Removed vehicle sysid" << sysid;
}

void FleetRegistry::clearAll()
{
    for (uint8_t sysid : _enrolledBySysid.keys()) {
        removeVehicle(sysid);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Session persistence
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::saveSession()
{
    QSettings s;
    s.beginWriteArray(QStringLiteral("FleetRegistry/vehicles"));
    int idx = 0;
    for (auto* ev : _enrolledBySysid) {
        s.setArrayIndex(idx++);
        s.setValue(QStringLiteral("sysid"),     ev->sysid());
        s.setValue(QStringLiteral("mavType"),   ev->mavType());
        s.setValue(QStringLiteral("vehicleId"), ev->vehicleId());
        s.setValue(QStringLiteral("typeStr"),   ev->typeString());
        s.setValue(QStringLiteral("role"),      ev->role());
    }
    s.endArray();
}

void FleetRegistry::loadSession()
{
    QSettings s;
    const int count = s.beginReadArray(QStringLiteral("FleetRegistry/vehicles"));
    for (int i = 0; i < count; ++i) {
        s.setArrayIndex(i);
        const uint8_t sysid   = static_cast<uint8_t>(s.value(QStringLiteral("sysid"),   0).toInt());
        const uint8_t mavType = static_cast<uint8_t>(s.value(QStringLiteral("mavType"), 0).toInt());
        const QString id      = s.value(QStringLiteral("vehicleId")).toString();
        const QString typeStr = s.value(QStringLiteral("typeStr")).toString();
        const QString role    = s.value(QStringLiteral("role")).toString();

        if (_enrolledBySysid.contains(sysid)) continue;

        auto* ev = new EnrolledVehicle(sysid, mavType, id, typeStr, role, this);
        ev->setLinkState(EnrolledVehicle::Offline);
        _enrolledBySysid[sysid] = ev;
        _enrolledList->append(ev);
    }
    s.endArray();

    if (count > 0) emit enrolledVehiclesChanged();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Role map persistence
// ─────────────────────────────────────────────────────────────────────────────

void FleetRegistry::saveRoleMap()
{
    QSettings s;
    s.beginGroup(QStringLiteral("FleetRegistry/roleMap"));
    s.remove(QString());
    for (auto it = _roleMap.cbegin(); it != _roleMap.cend(); ++it) {
        s.setValue(QString::number(it.key()), it.value());
    }
    s.endGroup();
}

void FleetRegistry::loadRoleMap()
{
    QSettings s;
    s.beginGroup(QStringLiteral("FleetRegistry/roleMap"));
    const QStringList keys = s.childKeys();
    if (!keys.isEmpty()) {
        for (const QString& key : keys) {
            _roleMap[static_cast<uint8_t>(key.toInt())] = s.value(key).toString();
        }
    } else {
        _roleMap[1]  = QStringLiteral("Strike");
        _roleMap[2]  = QStringLiteral("ISR");
        _roleMap[10] = QStringLiteral("Scout");
        _roleMap[13] = QStringLiteral("Strike");
        _roleMap[19] = QStringLiteral("Strike");
    }
    s.endGroup();
}
