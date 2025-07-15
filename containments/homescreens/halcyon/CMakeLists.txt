# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

plasma_add_applet(org.kde.plasma.mobile.homescreen.halcyon
    QML_SOURCES
        qml/Clock.qml
        qml/FavoritesAppDelegate.qml
        qml/FavoritesGrid.qml
        qml/FavoritesView.qml
        qml/FolderGrid.qml
        qml/GridAppDelegate.qml
        qml/GridAppList.qml
        qml/HomeScreen.qml
        qml/main.qml
        qml/SearchWidget.qml
    CPP_SOURCES
        application.cpp
        applicationfolder.cpp
        applicationlistmodel.cpp
        halcyonsettings.cpp
        homescreen.cpp
        pinnedmodel.cpp
        windowlistener.cpp
)

ecm_target_qml_sources(org.kde.plasma.mobile.homescreen.halcyon SOURCES
    qml/settings/SettingsScreen.qml
    qml/settings/SettingsWindow.qml
    PATH settings
)

target_link_libraries(org.kde.plasma.mobile.homescreen.halcyon PRIVATE
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      Plasma::Plasma
                      Plasma::KWaylandClient
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::JobWidgets
                      KF6::WindowSystem)
