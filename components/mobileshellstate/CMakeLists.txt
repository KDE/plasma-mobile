# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(mobileshellstateplugin_SRCS
    shelldbusobject.cpp
    shelldbusclient.cpp
    lockscreendbusclient.cpp
    startupfeedbackmodel.cpp
    windowlistener.cpp
    volumeosdlistener.cpp
)

qt_generate_dbus_interface(
    ${CMAKE_CURRENT_SOURCE_DIR}/shelldbusobject.h
    org.kde.plasmashell.Mobile.xml
    OPTIONS -s -m -P
)

qt_add_dbus_adaptor(mobileshellstateplugin_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasmashell.Mobile.xml
                    ${CMAKE_CURRENT_SOURCE_DIR}/shelldbusobject.h ShellDBusObject)
qt_add_dbus_interface(mobileshellstateplugin_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasmashell.Mobile.xml plasmashellmobileinterface)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasmashell.Mobile.xml DESTINATION ${KDE_INSTALL_DBUSINTERFACEDIR})


ecm_add_qml_module(mobileshellstateplugin URI org.kde.plasma.private.mobileshell.state GENERATE_PLUGIN_SOURCE)

target_sources(mobileshellstateplugin PRIVATE ${mobileshellstateplugin_SRCS} ${RESOURCES})

target_link_libraries(mobileshellstateplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        Qt::DBus
        Plasma::Plasma
        Plasma::KWaylandClient
        KF6::I18n
        KF6::Notifications
        Plasma::PlasmaQuick
)

ecm_finalize_qml_module(mobileshellstateplugin)
