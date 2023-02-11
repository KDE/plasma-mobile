# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: LGPL-2.1-or-later

function(add_kwin_script name)
    kpackage_install_package(${name} ${name} scripts kwin)

    # Copy the script to the build directory so one can run tests without prior
    # make install. FIXME: use add_custom_command.
    file(COPY ${name} DESTINATION ${CMAKE_BINARY_DIR}/bin/kwin/scripts/)
endfunction()

add_kwin_script(convergentwindows)

