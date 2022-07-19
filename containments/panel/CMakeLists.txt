# SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2020-2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(phonepanel_SRCS
    phonepanel.cpp
)

add_library(plasma_applet_phonepanel MODULE ${phonepanel_SRCS})

target_link_libraries(plasma_applet_phonepanel
                      Qt::Gui
                      Qt::DBus
                      KF5::Plasma
                      KF5::I18n
                      KF5::Service
                     )

install(TARGETS plasma_applet_phonepanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-phonepanel-default.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})

plasma_install_package(package org.kde.phone.panel)

