# ============================================================================
# QGroundControl CMake Build Configuration
# STRATUM - Optimized for Fast Loading
# ============================================================================

cmake_minimum_required(VERSION 3.25)

# ============================================================================
# Speed Optimizations
# ============================================================================

set(QGC_BUILD_TESTING OFF CACHE BOOL "Disable testing" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "Disable testing" FORCE)
set(QGC_ENABLE_QMLLINT OFF CACHE BOOL "Disable QML linting" FORCE)

set(CPM_SOURCE_CACHE "${CMAKE_SOURCE_DIR}/.cpm_cache" CACHE PATH "CPM cache directory")
set(CPM_USE_LOCAL_PACKAGES ON CACHE BOOL "Use local packages")

set(CMAKE_SKIP_RPATH ON)
set(CMAKE_SKIP_INSTALL_RPATH ON)

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

# ============================================================================
# Module Paths
# ============================================================================

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/cmake"
    "${CMAKE_SOURCE_DIR}/cmake/modules"
)

include(Helpers)

# ============================================================================
# Build Type
# ============================================================================

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

# ============================================================================
# Project
# ============================================================================

include(CustomOptions)

project(${QGC_APP_NAME}
    VERSION ${QGC_APP_VERSION}
    DESCRIPTION ${QGC_APP_DESCRIPTION}
    LANGUAGES C CXX
)

include(GNUInstallDirs)
include(FetchContent)
include(CPM)
include(Toolchain)

# ============================================================================
# Enable GStreamer Video Streaming  ✅ ADDED
# ============================================================================

option(QGC_ENABLE_GST_VIDEOSTREAMING "Enable GStreamer Video" ON)

if(QGC_ENABLE_GST_VIDEOSTREAMING)
    message(STATUS "GStreamer Video Streaming ENABLED")
    add_compile_definitions(QGC_GST_STREAMING)
else()
    message(STATUS "GStreamer Video Streaming DISABLED")
endif()

# ============================================================================
# Output Directories
# ============================================================================

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

# ============================================================================
# Qt6 Configuration
# ============================================================================

set(QT_NO_PRIVATE_MODULE_WARNING ON)
set(QGC_QT_REQUIRED_VERSION 6.10)

find_package(Qt6 ${QGC_QT_REQUIRED_VERSION}
    REQUIRED
    COMPONENTS
        Charts
        Concurrent
        Core
        Core5Compat
        Gui
        HttpServer
        LinguistTools
        Location
        LocationPrivate
        Multimedia
        Network
        Positioning
        Qml
        QmlIntegration
        Quick
        QuickControls2
        QuickWidgets
        Sensors
        Sql
        Svg
        TextToSpeech
        Widgets
        Xml
        StateMachine
    OPTIONAL_COMPONENTS
        Bluetooth
        MultimediaQuickPrivate
        OpenGL
        Quick3D
        QuickTest
        SerialPort
        Test
)

if(Linux)
    find_package(Qt6 COMPONENTS WaylandClient)
endif()

qt_standard_project_setup(
    REQUIRES ${QGC_QT_REQUIRED_VERSION}
    I18N_SOURCE_LANGUAGE en
)

if(COMMAND qt_policy)
    qt_policy(
        SET QTP0001 NEW
        SET QTP0002 NEW
        SET QTP0003 NEW
        SET QTP0004 NEW
        SET QTP0005 NEW
    )
endif()

# ============================================================================
# Resources
# ============================================================================

list(APPEND QGC_RESOURCES
    "${CMAKE_SOURCE_DIR}/qgcimages.qrc"
    "${CMAKE_SOURCE_DIR}/qgcresources.qrc"
    "${CMAKE_SOURCE_DIR}/resources/InstrumentValueIcons/InstrumentValueIcons.qrc"
)

qt_add_executable(${CMAKE_PROJECT_NAME}
    WIN32
    MACOSX_BUNDLE
    ${QGC_RESOURCES}
)

# ============================================================================
# Platform
# ============================================================================

if(WIN32)
    include(Windows)
elseif(APPLE)
    include(Apple)
elseif(ANDROID)
    include(Android)
elseif(Linux)
    include(Linux)
endif()

# ============================================================================
# QML Module
# ============================================================================

qt_add_qml_module(${CMAKE_PROJECT_NAME}
    URI QGC
    VERSION 1.0
    RESOURCE_PREFIX /qml
    IMPORTS
        QtQuick
        QtQuick.Controls
        QtQuick.Dialogs
        QtQuick.Layouts
)

# ============================================================================
# Subdirectories
# ============================================================================

add_subdirectory(src)

# ============================================================================
# Translations
# ============================================================================

file(GLOB TS_SOURCES "${CMAKE_SOURCE_DIR}/translations/qgc_*.ts")

qt_add_translations(${CMAKE_PROJECT_NAME}
    TS_FILES ${TS_SOURCES}
    RESOURCE_PREFIX "/"
    LUPDATE_OPTIONS -no-obsolete
)

# ============================================================================
# Plugins
# ============================================================================

qt_import_plugins(${CMAKE_PROJECT_NAME}
    INCLUDE Qt6::QSvgPlugin
)

if(Linux)
    qt_import_plugins(${CMAKE_PROJECT_NAME}
        INCLUDE
            Qt6::QWaylandIntegrationPlugin
            Qt6::QXcbIntegrationPlugin
            Qt6::QEglFSIntegrationPlugin
    )
endif()

# ============================================================================
# Install & Summary
# ============================================================================

include(PrintSummary)
