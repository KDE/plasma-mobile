# Find ActiveApp - library to build simple active applications
#
# This module defines
#  ACTIVEAPP_FOUND - whether the qsjon library was found
#  ACTIVEAPP_LIBRARIES - the activeapp library
#  ACTIVEAPP_INCLUDE_DIR - the include path of the activeapp library
#

if (ACTIVEAPP_INCLUDE_DIR AND ACTIVEAPP_LIBRARIES)

  # Already in cache
  set (ACTIVEAPP_FOUND TRUE)

else (ACTIVEAPP_INCLUDE_DIR AND ACTIVEAPP_LIBRARIES)

  if (NOT WIN32)
    # use pkg-config to get the values of ACTIVEAPP_INCLUDE_DIRS
    # and ACTIVEAPP_LIBRARY_DIRS to add as hints to the find commands.
    include (FindPkgConfig)
    pkg_check_modules (ACTIVEAPP ActiveApp>=0.1)
  endif (NOT WIN32)

  find_library (ACTIVEAPP_LIBRARIES
    NAMES
    activeapp
    PATHS
    ${ACTIVEAPP_LIBRARY_DIRS}
    ${LIB_INSTALL_DIR}
    ${KDE4_LIB_DIR}
  )

  find_path (ACTIVEAPP_INCLUDE_DIR
    NAMES
    session.h
    PATH_SUFFIXES
    activeapp
    PATHS
    ${ACTIVEAPP_INCLUDE_DIRS}
    ${INCLUDE_INSTALL_DIR}
    ${KDE4_INCLUDE_DIR}
  )

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(ACTIVEAPP DEFAULT_MSG ACTIVEAPP_LIBRARIES ACTIVEAPP_INCLUDE_DIR)

endif (ACTIVEAPP_INCLUDE_DIR AND ACTIVEAPP_LIBRARIES)
