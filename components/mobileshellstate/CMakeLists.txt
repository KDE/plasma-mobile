# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
                                 
set(mobileshellstateplugin_SRCS
    mobileshellstateplugin.cpp
)
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
        KF6::Plasma
        KF6::I18n
        KF6::Notifications
        KF6::PlasmaQuick
)

# we compiled the qml files, just install qmldir
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

ecm_generate_qmltypes(org.kde.plasma.private.mobileshell.state 1.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)
install(TARGETS mobileshellstateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

