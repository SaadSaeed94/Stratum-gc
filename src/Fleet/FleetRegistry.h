#pragma once

#include <QObject>
#include <QMap>
#include <QTimer>
#include <QSettings>
#include <QtQml/qqml.h>

#include "EnrolledVehicle.h"
#include "MAVLinkLib.h"         // for mavlink_message_t
#include "QmlObjectListModel.h" // must be fully defined for Q_PROPERTY + MOC

class FleetRegistry : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(FleetRegistry)
    QML_SINGLETON

    Q_PROPERTY(QmlObjectListModel* enrolledVehicles READ enrolledVehicles NOTIFY enrolledVehiclesChanged)
    Q_PROPERTY(QVariantMap         roleMap          READ roleMap          NOTIFY roleMapChanged)

public:
    // Qt6 singleton factory — called by QML engine
    static FleetRegistry* create(QQmlEngine*, QJSEngine*) {
        return instance();
    }
    static FleetRegistry* instance();

    Q_INVOKABLE void             setRoleForType(int mavType, const QString& role);
    Q_INVOKABLE QString          roleForType(int mavType) const;
    Q_INVOKABLE EnrolledVehicle* vehicleForSysid(int sysid) const;
    Q_INVOKABLE void             removeVehicle(int sysid);
    Q_INVOKABLE void             clearAll();

    QmlObjectListModel* enrolledVehicles() const { return _enrolledList; }
    QVariantMap         roleMap()          const;

            // Called by FleetConfigLoader to pre-enroll a vehicle from JSON
    void preEnroll(uint8_t sysid, const QString& vehicleId,
                   const QString& role, uint8_t mavType = 0);

            // Called by MAVLink heartbeat handler
    void processHeartbeat(uint8_t sysid, uint8_t mavType, uint8_t autopilot);

            // Called by MAVLink message handler — registry decodes the message itself
    void processCameraInformation(const mavlink_message_t& message);

signals:
    void enrolledVehiclesChanged();
    void roleMapChanged();
    void vehicleEnrolled(int sysid);
    void vehicleLinkLost(int sysid);
    void vehicleLinkRecovered(int sysid);
    void cameraInfoReceived(int sysid);

private:
    explicit FleetRegistry(QObject* parent = nullptr);

    void    onHeartbeatTimeout(uint8_t sysid);
    void    requestCameraInformation(uint8_t sysid);
    QString typeStringFromMAVType(uint8_t mavType) const;
    QString roleFromMAVType(uint8_t mavType) const;
    void    saveSession();
    void    loadSession();
    void    saveRoleMap();
    void    loadRoleMap();

    QMap<uint8_t, EnrolledVehicle*> _enrolledBySysid;
    QMap<uint8_t, QTimer*>          _heartbeatTimers;
    QmlObjectListModel*             _enrolledList   = nullptr;
    QMap<uint8_t, QString>          _roleMap;

    static constexpr int HEARTBEAT_TIMEOUT_MS    = 5000;
    static constexpr int CAMERA_REQUEST_DELAY_MS = 500;
};
