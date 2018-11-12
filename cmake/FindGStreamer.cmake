# - Try to find GStreamer
# Once done this will define
#
#  GSTREAMER_FOUND - system has GStreamer
#  GSTREAMER_INCLUDE_DIR - the GStreamer include directory
#  GSTREAMER_LIBRARY - the main GStreamer library
#  GSTREAMER_PLUGIN_DIR - the GStreamer plugin directory
#
#  And for all the plugin libraries specified in the COMPONENTS
#  of find_package, this module will define:
#
#  GSTREAMER_<plugin_lib>_LIBRARY_FOUND - system has <plugin_lib>
#  GSTREAMER_<plugin_lib>_LIBRARY - the <plugin_lib> library
#  GSTREAMER_<plugin_lib>_INCLUDE_DIR - the <plugin_lib> include directory
#
# Copyright(c) 2010, Collabora Ltd.
#   @author George Kiagiadakis <george.kiagiadakis@collabora.co.uk>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

# TODO: Other versions --> GSTREAMER_X_Y_FOUND(Example: GSTREAMER_0_8_FOUND and GSTREAMER_0_10_FOUND etc)

if(GSTREAMER_INCLUDE_DIR AND GSTREAMER_LIBRARIES AND GSTREAMER_BASE_LIBRARY)
   # in cache already
   set(GStreamer_FIND_QUIETLY TRUE)
else()
   set(GStreamer_FIND_QUIETLY FALSE)
endif()

set(GSTREAMER_API_VERSION 1.0)
if(NOT WIN32)
   FIND_PACKAGE(PkgConfig REQUIRED)
   # use pkg-config to get the directories and then use these values
   # in the FIND_PATH() and FIND_LIBRARY() calls
   # don't make this check required - otherwise you can't use macro_optional_find_package on this one
   PKG_CHECK_MODULES(PKG_GSTREAMER gstreamer-${GSTREAMER_API_VERSION})
   set(GSTREAMER_VERSION ${PKG_GSTREAMER_VERSION})
   set(GSTREAMER_DEFINITIONS ${PKG_GSTREAMER_CFLAGS})
endif()

message(STATUS "Found GStreamer package: ${PKG_GSTREAMER_VERSION}")

set(GSTREAMER_INCLUDE_DIR ${PKG_GSTREAMER_INCLUDE_DIRS})

find_library(GSTREAMER_LIBRARIES NAMES gstreamer-${GSTREAMER_API_VERSION}
   PATHS
   ${PKG_GSTREAMER_LIBRARY_DIRS}
   )

find_library(GSTREAMER_BASE_LIBRARY NAMES gstbase-${GSTREAMER_API_VERSION}
   PATHS
   ${PKG_GSTREAMER_LIBRARY_DIRS}
   )

find_library(GSTREAMER_VIDEO_LIBRARY NAMES gstvideo-${GSTREAMER_API_VERSION}
   PATHS
   ${PKG_GSTREAMER_LIBRARY_DIRS}
   )

if(NOT GSTREAMER_INCLUDE_DIR)
   message(STATUS "GStreamer: WARNING: include dir not found")
endif()

if(NOT GSTREAMER_LIBRARIES)
   message(STATUS "GStreamer: WARNING: library not found")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GStreamer  DEFAULT_MSG  GSTREAMER_LIBRARIES GSTREAMER_INCLUDE_DIR GSTREAMER_BASE_LIBRARY)

mark_as_advanced(GSTREAMER_INCLUDE_DIR GSTREAMER_LIBRARIES GSTREAMER_BASE_LIBRARY)
