# STRATUM Custom Build Overrides
# NexamSystems - Command and Control

message(STATUS "STRATUM: Applying custom build overrides")

# Application branding (already set in QGCApplication.cc)
# These are informational only - actual values are in source code

# Custom build flag
set(QGC_CUSTOM_BUILD ON CACHE BOOL "STRATUM custom build" FORCE)

message(STATUS "STRATUM: Custom overrides applied")
