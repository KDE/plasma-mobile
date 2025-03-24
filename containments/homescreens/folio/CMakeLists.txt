# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.mobile.homescreen.folio\")

set(homescreen_SRCS
    homescreen.cpp
    applicationlistmodel.cpp
    homescreenstate.cpp
    windowlistener.cpp
    favouritesmodel.cpp
    folioapplication.cpp
    folioapplicationfolder.cpp
    foliodelegate.cpp
    foliosettings.cpp
    foliowidget.cpp
    pagemodel.cpp
    pagelistmodel.cpp
    delegatetoucharea.cpp
    dragstate.cpp
    widgetcontainer.cpp
    widgetsmanager.cpp
    keyboardnavigation.cpp
    enums.h
)

add_library(org.kde.plasma.mobile.homescreen.folio MODULE ${homescreen_SRCS})

target_link_libraries(org.kde.plasma.mobile.homescreen.folio
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      Plasma::Plasma
                      Plasma::PlasmaQuick
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::Notifications
                      Plasma::KWaylandClient
                      KF6::WindowSystem
                      KF6::JobWidgets
)

install(TARGETS org.kde.plasma.mobile.homescreen.folio DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.homescreen.folio)
