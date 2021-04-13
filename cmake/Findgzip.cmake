# Finds gzip.
#
#  gzip_FOUND     - True if gzip is found.
#  gzip_EXECUTABLE - Path to executable

#=============================================================================
# SPDX-FileCopyrightText: 2019 Friedrich W. H. Kossebau <kossebau@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause
#=============================================================================

find_program(gzip_EXECUTABLE NAMES gzip)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(gzip
    FOUND_VAR
        gzip_FOUND
    REQUIRED_VARS
        gzip_EXECUTABLE
)
mark_as_advanced(gzip_EXECUTABLE)

set_package_properties(gzip PROPERTIES
    URL "https://www.gnu.org/software/gzip"
    DESCRIPTION "Data compression program for the gzip format"
)
