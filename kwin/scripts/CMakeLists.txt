# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: LGPL-2.1-or-later

function(add_kwin_script name source)
    kpackage_install_package(${source} ${name} scripts kwin)

    # Copy the script to the build directory so one can run tests without prior
    # make install.
    file(COPY ${source}/contents ${source}/metadata.json DESTINATION ${CMAKE_BINARY_DIR}/bin/kwin/scripts/${name})
endfunction()

add_kwin_script(mobilewindows mobilewindows)
add_kwin_script(dockedwindows dockedwindows)


