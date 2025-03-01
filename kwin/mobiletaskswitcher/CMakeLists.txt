# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kpackage_install_package(package mobiletaskswitcher effects kwin)

# Copy the script to the build directory so one can run tests without prior
# make install.
file(COPY package/contents package/metadata.json DESTINATION ${CMAKE_BINARY_DIR}/bin/kwin/effects/mobiletaskswitcher)

add_subdirectory(plugin)