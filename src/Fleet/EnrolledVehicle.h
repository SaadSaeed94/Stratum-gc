#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QtQml/qqml.h>

// ─────────────────────────────────────────────
//  Camera payload info (from CAMERA_INFORMATION #259)
// ─────────────────────────────────────────────
struct CameraInfo {
    float   hfov         = 0.0f;
    float   vfov         = 0.0f;
    float   focalLength  = 0.0f;
    float   sensorWidth  = 0.0f;
    float   sensorHeight = 0.0f;
    QString modelName;
    bool    valid        = false;
};

// ─────────────────────────────────────────────
//  Single enrolled vehicle record
// ─────────────────────────────────────────────
class EnrolledVehicle : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("EnrolledVehicle is created by FleetRegistry")

    Q_PROPERTY(int      sysid       READ sysid        CONSTANT)
    Q_PROPERTY(int      mavType     READ mavType      CONSTANT)
    Q_PROPERTY(QString  vehicleId   READ vehicleId    NOTIFY infoChanged)
    Q_PROPERTY(QString  typeString  READ typeString   NOTIFY infoChanged)
    Q_PROPERTY(QString  role        READ role         WRITE setRole  NOTIFY infoChanged)
    Q_PROPERTY(QString  linkState   READ linkStateStr NOTIFY linkStateChanged)
    Q_PROPERTY(bool     online      READ online       NOTIFY linkStateChanged)
    Q_PROPERTY(QDateTime lastSeen   READ lastSeen     NOTIFY linkStateChanged)

    // Camera
    Q_PROPERTY(bool    cameraValid   READ cameraValid   NOTIFY cameraInfoChanged)
    Q_PROPERTY(float   cameraHFoV   READ cameraHFoV    NOTIFY cameraInfoChanged)
    Q_PROPERTY(float   cameraVFoV   READ cameraVFoV    NOTIFY cameraInfoChanged)
    Q_PROPERTY(float   focalLength  READ focalLength   NOTIFY cameraInfoChanged)
    Q_PROPERTY(float   sensorWidth  READ sensorWidth   NOTIFY cameraInfoChanged)
    Q_PROPERTY(float   sensorHeight READ sensorHeight  NOTIFY cameraInfoChanged)
    Q_PROPERTY(QString cameraModel  READ cameraModel   NOTIFY cameraInfoChanged)

public:
    enum LinkState { Online, LinkLost, Offline };
    Q_ENUM(LinkState)

    explicit EnrolledVehicle(uint8_t sysid, uint8_t mavType,
                              const QString& vehicleId,
                              const QString& typeString,
                              const QString& role,
                              QObject* parent = nullptr);

    int         sysid()       const { return _sysid; }
    int         mavType()     const { return _mavType; }
    QString     vehicleId()   const { return _vehicleId; }
    QString     typeString()  const { return _typeString; }
    QString     role()        const { return _role; }
    LinkState   linkState()   const { return _linkState; }
    bool        online()      const { return _linkState == Online; }
    QDateTime   lastSeen()    const { return _lastSeen; }

    QString linkStateStr() const {
        switch (_linkState) {
            case Online:   return QStringLiteral("Online");
            case LinkLost: return QStringLiteral("LinkLost");
            default:       return QStringLiteral("Offline");
        }
    }

    bool    cameraValid()   const { return _camera.valid; }
    float   cameraHFoV()   const { return _camera.hfov; }
    float   cameraVFoV()   const { return _camera.vfov; }
    float   focalLength()  const { return _camera.focalLength; }
    float   sensorWidth()  const { return _camera.sensorWidth; }
    float   sensorHeight() const { return _camera.sensorHeight; }
    QString cameraModel()  const { return _camera.modelName; }

    void setRole(const QString& role);
    void setLinkState(LinkState state);
    void updateHeartbeat();
    void setCameraInfo(const CameraInfo& info);

signals:
    void infoChanged();
    void linkStateChanged();
    void cameraInfoChanged();

private:
    uint8_t    _sysid;
    uint8_t    _mavType;
    QString    _vehicleId;
    QString    _typeString;
    QString    _role;
    LinkState  _linkState = Offline;
    QDateTime  _lastSeen;
    CameraInfo _camera;
};
