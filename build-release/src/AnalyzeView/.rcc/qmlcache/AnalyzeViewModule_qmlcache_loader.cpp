#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qml_QGroundControl_AnalyzeView_AnalyzeView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AnalyzeView_LogDownloadPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AnalyzeView_MAVLinkConsolePage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AnalyzeView_MAVLinkInspectorPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qml_QGroundControl_AnalyzeView_VibrationPage_qml { 
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
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AnalyzeView/AnalyzeView.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AnalyzeView_AnalyzeView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AnalyzeView/LogDownloadPage.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AnalyzeView_LogDownloadPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AnalyzeView/MAVLinkConsolePage.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AnalyzeView_MAVLinkConsolePage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AnalyzeView/MAVLinkInspectorPage.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AnalyzeView_MAVLinkInspectorPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qml/QGroundControl/AnalyzeView/VibrationPage.qml"), &QmlCacheGeneratedCode::_qml_QGroundControl_AnalyzeView_VibrationPage_qml::unit);
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
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_AnalyzeViewModule)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_AnalyzeViewModule))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_AnalyzeViewModule)() {
    return 1;
}
