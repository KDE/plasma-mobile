# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
                                 
set(mobileshellstateplugin_SRCS
    mobileshellstateplugin.cpp
    shelldbusobject.cpp
    shelldbusclient.cpp
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

qt_add_resources(RESOURCES resources.qrc)
add_library(mobileshellstateplugin SHARED ${mobileshellstateplugin_SRCS} ${RESOURCES})

target_link_libraries(mobileshellstateplugin 
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        Qt::DBus
        KF6::Plasma
        KF6::I18n
        KF6::Notifications
        KF6::PlasmaQuick
)

# we compiled the qml files, just install qmldir
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

ecm_generate_qmltypes(org.kde.plasma.private.mobileshell.state 1.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)
install(TARGETS mobileshellstateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

