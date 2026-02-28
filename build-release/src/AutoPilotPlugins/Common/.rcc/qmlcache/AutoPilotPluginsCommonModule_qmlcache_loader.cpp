#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qml_QGroundControl_AutoPilotPlugins_Common_ESP8266Component_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_ESP8266ComponentSummary_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_ScriptingComponent_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_JoystickComponentSummary_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_MotorComponent_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_RadioComponent_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AutoPilotPlugins_Common_SyslinkComponent_qml { 
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
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/ESP8266Component.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_ESP8266Component_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/ESP8266ComponentSummary.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_ESP8266ComponentSummary_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/ScriptingComponent.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_ScriptingComponent_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/JoystickComponentSummary.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_JoystickComponentSummary_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/MotorComponent.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_MotorComponent_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/RadioComponent.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_RadioComponent_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AutoPilotPlugins/Common/SyslinkComponent.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AutoPilotPlugins_Common_SyslinkComponent_qml::unit);
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
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_AutoPilotPluginsCommonModule)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_AutoPilotPluginsCommonModule))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_AutoPilotPluginsCommonModule)() {
    return 1;
}
