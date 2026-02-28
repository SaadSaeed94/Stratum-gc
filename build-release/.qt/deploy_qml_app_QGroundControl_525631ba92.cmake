include("/home/saad-saeed/qgroundcontrol/build-release/.qt/QtDeploySupport.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/QGroundControl-plugins.cmake" OPTIONAL)
set(__QT_DEPLOY_I18N_CATALOGS "qtbase;qtwebsockets;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtmultimedia;qtdeclarative;qtdeclarative;qtdeclarative;qtconnectivity;qtmultimedia;qtdeclarative;qtdeclarative;qtdeclarative;qtdeclarative;qtserialport")

qt6_deploy_qml_imports(TARGET QGroundControl PLUGINS_FOUND plugins_found)
qt6_deploy_runtime_dependencies(
    EXECUTABLE "/home/saad-saeed/qgroundcontrol/build-release/Release/QGroundControl"
    ADDITIONAL_MODULES ${plugins_found}
    GENERATE_QT_CONF
INCLUDE_PLUGINS;qwayland)