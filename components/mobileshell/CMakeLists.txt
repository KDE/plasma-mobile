# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(mobileshellplugin URI org.kde.plasma.private.mobileshell GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

set(mobileshellplugin_SRCS
    shellutil.cpp
    components/direction.cpp
    components/direction.h
    components/swipearea.cpp
    notifications/notificationthumbnailer.cpp
    notifications/notificationfilemenu.cpp
    notifications/notificationfileinfo.cpp
    masklayer/masklayer.cpp
    masklayer/maskmanager.cpp
)
target_include_directories(mobileshellplugin PRIVATE components)
target_include_directories(mobileshellplugin PRIVATE notifications)
target_include_directories(mobileshellplugin PRIVATE masklayer)
target_sources(mobileshellplugin PRIVATE ${mobileshellplugin_SRCS})

# Singleton declarations
set_source_files_properties(
    qml/components/AppLaunch.qml
    qml/components/Constants.qml
    qml/dataproviders/AudioInfo.qml
    qml/dataproviders/BatteryInfo.qml
    qml/dataproviders/BluetoothInfo.qml
    qml/dataproviders/NetworkInfo.qml
    qml/dataproviders/SignalStrengthInfo.qml
    qml/popups/PopupProviderLoader.qml
    PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

# Include qml and js files within ./qml/
file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
    "qml/*.js"
)
ecm_target_qml_sources(mobileshellplugin SOURCES ${_qml_sources})


target_link_libraries(mobileshellplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        Qt::WaylandClientPrivate
        KF6::KIOGui
        Plasma::Plasma
        KF6::I18n
        KF6::Notifications
        Plasma::PlasmaQuick
        KF6::KIOGui
        KF6::KIOWidgets # for PreviewJob
        KF6::Service
        KF6::Package
        KF6::ConfigGui
        LayerShellQt::Interface
)

ecm_finalize_qml_module(mobileshellplugin)
