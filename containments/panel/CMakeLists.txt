# SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2020-2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(phonepanel_SRCS
    phonepanel.cpp
)

add_library(org.kde.plasma.mobile.panel MODULE ${phonepanel_SRCS})

target_link_libraries(org.kde.plasma.mobile.panel
                      Qt::Gui
                      Qt::DBus
                      Plasma::Plasma
                      KF6::I18n
                      KF6::Service
                     )

install(TARGETS org.kde.plasma.mobile.panel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-phonepanel-default.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})

plasma_install_package(package org.kde.plasma.mobile.panel)

