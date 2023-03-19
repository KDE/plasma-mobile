# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
                                 
set(mobileshellplugin_SRCS
    mobileshellplugin.cpp
    shellutil.cpp
    components/direction.cpp
    notifications/notificationthumbnailer.cpp
    notifications/notificationfilemenu.cpp
)
qt_add_resources(RESOURCES resources.qrc)
add_library(mobileshellplugin SHARED ${mobileshellplugin_SRCS} ${RESOURCES})

target_link_libraries(mobileshellplugin 
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        KF6::ConfigWidgets # for KStandardAction
        KF6::KIOGui
        KF6::Plasma
        KF6::I18n
        KF6::Notifications
        KF6::PlasmaQuick
        KF6::KIOGui
        KF6::KIOWidgets # for PreviewJob
        KF6::WaylandClient
        KF6::Service
        KF6::Package
)

# we compiled the qml files, just install qmldir
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)

ecm_generate_qmltypes(org.kde.plasma.private.mobileshell 1.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)
install(TARGETS mobileshellplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)
