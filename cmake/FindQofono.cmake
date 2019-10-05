#=============================================================================
# Copyright (c) 2019 Bhushan Shah <bshah@kde.org>
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

find_package(PkgConfig)
pkg_check_modules(PC_Qofono QUIET qofono-qt5)

find_path(Qofono_INCLUDE_DIR
    NAMES qofono.h
    PATHS ${PC_Qofono_INCLUDE_DIRS}
    PATH_SUFFIXES qofono-qt5
)

find_library(Qofono_LIBRARY
    NAMES qofono-qt5
    PATHS ${PC_Qofono_LIBRARY_DIRS}
)

set(Qofono_VERSION ${PC_Qofono_VERSION})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Qofono
    FOUND_VAR Qofono_FOUND
    REQUIRED_VARS
        Qofono_LIBRARY
        Qofono_INCLUDE_DIR
    VERSION_VAR Qofono_VERSION
)

if(Qofono_FOUND)
    set(Qofono_LIBRARIES ${Qofono_LIBRARY})
    set(Qofono_INCLUDE_DIRS ${Qofono_INCLUDE_DIR})
    set(Qofono_DEFINITIONS ${PC_Qofono_CFLAGS_OTHER})
endif()

mark_as_advanced(
    Qofono_INCLUDE_DIR
    Qofono_LIBRARY
)
