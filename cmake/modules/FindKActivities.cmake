#   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

# cmake macro to see if we have libKActivities

# KACTIVITIES_INCLUDE_DIR
# KACTIVITIES_FOUND
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

# Kinda stupid those are not set to QUIET and REQUIRED so i could just forward them.
set(_find_package_args)

if(${KActivities_FIND_QUIET})
    list(APPEND _find_package_args QUIET)
endif()

if(${KActivities_FIND_EXACT})
    list(APPEND _find_package_args EXACT)
endif()

if(${KActivities_FIND_REQUIRED})
    list(APPEND _find_package_args REQUIRED)
endif()

find_package(
    KActivities
    ${KActivities_FIND_VERSION}
    ${_find_package_args}
    NO_MODULE)

find_package_handle_standard_args(
    KActivities
    REQUIRED_VARS KACTIVITIES_INCLUDE_DIRS
    VERSION_VAR   COFIG_MODE)


