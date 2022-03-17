# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(folio_SRCS
    folio.cpp
    applicationlistmodel.cpp
    favoritesmodel.cpp
    homescreenutils.cpp
)

add_library(plasma_homescreen_folio MODULE ${folio_SRCS})

kcoreaddons_desktop_to_json(plasma_homescreen_folio package/metadata.desktop)

target_link_libraries(plasma_homescreen_folio
    Qt::Gui
    Qt::Qml
    Qt::Quick
    KF5::KIOGui
    KF5::Plasma
    KF5::Notifications
    KF5::PlasmaQuick
    KF5::WaylandClient
    PM::LibMobileShell
)


install(TARGETS plasma_homescreen_folio DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen.folio)

