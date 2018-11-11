# - Try to find the GLIB2 libraries
# Once done this will define
#
#  GLIB2_FOUND - system has glib2
#  GLIB2_INCLUDE_DIR - the glib2 include directory
#  GLIB2_LIBRARIES - glib2 library

# Copyright (c) 2008 Laurent Montel, <montel@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.


if(GLIB2_INCLUDE_DIR AND GLIB2_LIBRARIES)
    # Already in cache, be silent
    set(GLIB2_FIND_QUIETLY TRUE)
endif(GLIB2_INCLUDE_DIR AND GLIB2_LIBRARIES)

if (NOT WIN32)
   find_package(PkgConfig REQUIRED)
   pkg_check_modules(PKG_GLIB REQUIRED glib-2.0)
endif(NOT WIN32)

find_path(GLIB2_MAIN_INCLUDE_DIR glib.h
          PATH_SUFFIXES glib-2.0
          PATHS ${PKG_GLIB_INCLUDE_DIRS} )

# search the glibconfig.h include dir under the same root where the library is found
find_library(GLIB2_LIBRARIES
             NAMES glib-2.0
             PATHS ${PKG_GLIB_LIBRARY_DIRS} )

find_path(GLIB2_INTERNAL_INCLUDE_DIR glibconfig.h
          PATH_SUFFIXES glib-2.0/include ../lib/glib-2.0/include
          PATHS ${PKG_GLIB_INCLUDE_DIRS} ${PKG_GLIB_LIBRARIES} ${CMAKE_SYSTEM_LIBRARY_PATH})

set(GLIB2_INCLUDE_DIR ${GLIB2_MAIN_INCLUDE_DIR})

# not sure if this include dir is optional or required
# for now it is optional
if(GLIB2_INTERNAL_INCLUDE_DIR)
  set(GLIB2_INCLUDE_DIR ${GLIB2_INCLUDE_DIR} ${GLIB2_INTERNAL_INCLUDE_DIR})
endif(GLIB2_INTERNAL_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLIB2  DEFAULT_MSG  GLIB2_LIBRARIES GLIB2_MAIN_INCLUDE_DIR)

mark_as_advanced(GLIB2_INCLUDE_DIR GLIB2_LIBRARIES)
