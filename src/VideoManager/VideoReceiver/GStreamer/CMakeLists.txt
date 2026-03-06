# ============================================================================
# GStreamer Detection and Configuration
# ============================================================================

if(QGC_ENABLE_GST_VIDEOSTREAMING)

    message(STATUS "Configuring GStreamer backend")

    if(NOT MACOS)
        # ------------------------------------------------------------
        # Find GStreamer 1.0 using pkg-config
        # ------------------------------------------------------------
        find_package(PkgConfig REQUIRED)

        # Core required modules
        pkg_check_modules(GST REQUIRED
            gstreamer-1.0>=1.20
            gstreamer-base-1.0>=1.20
            gstreamer-video-1.0>=1.20
            gstreamer-audio-1.0>=1.20
            gstreamer-pbutils-1.0>=1.20
            gstreamer-allocators-1.0>=1.20
            gstreamer-gl-1.0>=1.20
            gstreamer-rtsp-1.0>=1.20
        )

        # Optional modules
        pkg_check_modules(GST_OPTIONAL
            gstreamer-gl-x11-1.0
            gstreamer-gl-wayland-1.0
            gstreamer-gl-egl-1.0
        )

        # Include paths
        target_include_directories(${CMAKE_PROJECT_NAME}
            PRIVATE
                ${GST_INCLUDE_DIRS}
        )

        # Compiler flags
        target_compile_options(${CMAKE_PROJECT_NAME}
            PRIVATE
                ${GST_CFLAGS_OTHER}
        )

    endif()

    # ------------------------------------------------------------
    # Build GStreamer Qt6 QML GL plugin
    # ------------------------------------------------------------
    add_subdirectory(gstqml6gl)
    add_subdirectory(gstqgc)

    target_sources(${CMAKE_PROJECT_NAME}
        PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}/GStreamer.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/GStreamerHelpers.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/GstVideoReceiver.cc
    )

    # ------------------------------------------------------------
    # Link GStreamer backend into main application
    # ------------------------------------------------------------
    target_link_libraries(${CMAKE_PROJECT_NAME}
        PRIVATE
            gstqml6gl
            ${GST_LIBRARIES}
    )

endif()
