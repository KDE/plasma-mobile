#.rst:
# FindPhoneNumber
# ---------------
#
# This module finds if PhoneNumber is installed.
# If found, this will define the following variables:
#
# ``PhoneNumber_FOUND``
#     Set to TRUE if PhoneNumber was found.
# ``PhoneNumber_LIBRARIES``
#     Path to PhoneNumber libraries.
# ``PhoneNumber_INCLUDE_DIR``
#     Path to the PhoneNumber include directory.
# ``PhoneNumberGeoCoding_LIBRARIES``
#     Path to PhoneNumber GeoCodeing libraries.
#
# If ``PhoneNumber_FOUND`` is TRUE the following imported targets
# will be defined:
#
# ``PhoneNumber::PhoneNumber``
#     The PhoneNumber library
# ``PhoneNumber::GeoCoding``
#     The PhoneNumber geo coding library
#

#=============================================================================
# Copyright (c) 2017 Klaralvdalens Datakonsult AB, a KDAB Group company, info@kdab.com
# Copyright (c) 2018 Volker Krause <vkrause@kde.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

include(FindPackageHandleStandardArgs)

find_library(PhoneNumber_LIBRARIES
        NAMES phonenumber
        PATH_SUFFIXES lib
        HINTS ENV PHONENUMBERDIR)

find_path(PhoneNumber_INCLUDE_DIR
        NAMES phonenumbers/phonenumberutil.h
        HINTS ENV PHONENUMBERDIR)

find_library(PhoneNumberGeoCoding_LIBRARIES
        NAMES geocoding
        PATH_SUFFIXES lib
        HINTS ENV PHONENUMBERDIR)

mark_as_advanced(PhoneNumber_LIBRARIES PhoneNumber_INCLUDE_DIR)
mark_as_advanced(PhoneNumberGeoCoding_LIBRARIES)

find_package_handle_standard_args(PhoneNumber DEFAULT_MSG PhoneNumber_LIBRARIES PhoneNumber_INCLUDE_DIR PhoneNumberGeoCoding_LIBRARIES)

if(PhoneNumber_FOUND AND NOT TARGET PhoneNumber::PhoneNumber)
    add_library(PhoneNumber::PhoneNumber UNKNOWN IMPORTED)
    set_target_properties(PhoneNumber::PhoneNumber PROPERTIES
        IMPORTED_LOCATION "${PhoneNumber_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${PhoneNumber_INCLUDE_DIR}")
    add_library(PhoneNumber::GeoCoding UNKNOWN IMPORTED)
    set_target_properties(PhoneNumber::GeoCoding PROPERTIES
        IMPORTED_LOCATION "${PhoneNumberGeoCoding_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${PhoneNumber_INCLUDE_DIR}")
endif()

include(FeatureSummary)
set_package_properties(PhoneNumber PROPERTIES
  URL "https://github.com/googlei18n/libphonenumber"
  DESCRIPTION "Library for parsing, formatting, and validating international phone numbers")
