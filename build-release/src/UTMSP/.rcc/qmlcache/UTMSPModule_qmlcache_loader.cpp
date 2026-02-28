#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPActivationStatusBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPAdapterEditor_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPFlightStatusIndicator_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPMapPolygonVisuals_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPMapVisuals_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPNotificationSlider_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_UTMSP_dummy_UTMSPStateStorage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPActivationStatusBar.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPActivationStatusBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPAdapterEditor.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPAdapterEditor_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPFlightStatusIndicator.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPFlightStatusIndicator_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPMapPolygonVisuals.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPMapPolygonVisuals_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPMapVisuals.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPMapVisuals_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPNotificationSlider.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPNotificationSlider_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/UTMSP/dummy/UTMSPStateStorage.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_UTMSP_dummy_UTMSPStateStorage_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_UTMSPModule)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_UTMSPModule))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_UTMSPModule)() {
    return 1;
}
