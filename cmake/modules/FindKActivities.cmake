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

if (KACTIVITIES_INCLUDE_DIR AND KACTIVITIES_LIBS)
   # Already in cache, be silent
   # This probably means that libKActivities is a part of the current
   # build or that this script was already invoked

   set(KActivities_FIND_QUIETLY TRUE)
   message("KActivities variables already set")
endif (KACTIVITIES_INCLUDE_DIR AND KACTIVITIES_LIBS)

if (NOT KActivities_FIND_QUIETLY)
   message("Searching for KActivities")

   find_path(KACTIVITIES_INCLUDE_DIR NAMES kactivities/consumer.h
      PATHS
      ${KDE4_INCLUDE_DIR}
      ${INCLUDE_INSTALL_DIR}
   )

   find_library(KACTIVITIES_LIBS NAMES kactivities
      PATHS
      ${KDE4_LIB_DIR}
      ${LIB_INSTALL_DIR}
   )

   include(FindPackageHandleStandardArgs)
   FIND_PACKAGE_HANDLE_STANDARD_ARGS(i
       KActivities DEFAULT_MSG KACTIVITIES_LIBS KACTIVITIES_INCLUDE_DIR )

   mark_as_advanced(KACTIVITIES_INCLUDE_DIR KACTIVITIES_LIBS)
endif (NOT KActivities_FIND_QUIETLY)

message("-- Found KActivities include dir: ${KACTIVITIES_INCLUDE_DIR}")
message("-- Found KActivities lib: ${KACTIVITIES_LIBS}")
