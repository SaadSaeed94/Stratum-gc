#include "EnrolledVehicle.h"

EnrolledVehicle::EnrolledVehicle(uint8_t sysid, uint8_t mavType,
                                  const QString& vehicleId,
                                  const QString& typeString,
                                  const QString& role,
                                  QObject* parent)
    : QObject(parent)
    , _sysid(sysid)
    , _mavType(mavType)
    , _vehicleId(vehicleId)
    , _typeString(typeString)
    , _role(role)
    , _lastSeen(QDateTime::currentDateTime())
{
}

void EnrolledVehicle::setRole(const QString& role)
{
    if (_role == role) return;
    _role = role;
    emit infoChanged();
}

void EnrolledVehicle::setLinkState(LinkState state)
{
    if (_linkState == state) return;
    _linkState = state;
    emit linkStateChanged();
}

void EnrolledVehicle::updateHeartbeat()
{
    _lastSeen = QDateTime::currentDateTime();
    setLinkState(Online);
}

void EnrolledVehicle::setCameraInfo(const CameraInfo& info)
{
    _camera = info;
    emit cameraInfoChanged();
}
