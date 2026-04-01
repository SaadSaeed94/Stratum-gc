# ============================================================================
# Fleet Module
# Vehicle enrollment, fleet registry, and config-based link management
# ============================================================================
qt_add_library(FleetModule STATIC)

qt_add_qml_module(FleetModule
    URI QGroundControl.Fleet
    VERSION 1.0
    RESOURCE_PREFIX /qml
    RESOURCES
        fleet.json
)

target_sources(FleetModule
    PRIVATE
        EnrolledVehicle.h
        EnrolledVehicle.cpp
        FleetRegistry.h
        FleetRegistry.cpp
        FleetConfigLoader.h
        FleetConfigLoader.cpp
)

target_include_directories(FleetModule PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src                # QGCApplication.h
    ${CMAKE_SOURCE_DIR}/src/MAVLink        # MAVLinkLib.h
    ${CMAKE_SOURCE_DIR}/src/QmlControls    # QmlObjectListModel.h
    ${CMAKE_SOURCE_DIR}/src/Comms
    ${CMAKE_SOURCE_DIR}/src/Vehicle          # LinkManager.h, TCPLink.h, UDPLink.h
    ${CMAKE_BINARY_DIR}/_deps/mavlink-build/include/mavlink/ardupilotmega
    ${CMAKE_BINARY_DIR}/_deps/mavlink-build/include/mavlink
    ${CMAKE_BINARY_DIR}/_deps/mavlink-build/include
)
target_link_libraries(FleetModule
    PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Network
        
)

