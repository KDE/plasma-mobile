# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
                                 
set(mobileshellstateplugin_SRCS
    mobileshellstateplugin.cpp
)
if (QT_MAJOR_VERSION STREQUAL "5")
    if(QUICK_COMPILER)
        qtquick_compiler_add_resources(RESOURCES resources.qrc)
    else()
        qt5_add_resources(RESOURCES resources.qrc)
    endif()
else()
    qt_add_resources(RESOURCES resources.qrc)
endif()
add_library(mobileshellstateplugin SHARED ${mobileshellstateplugin_SRCS} ${RESOURCES})

target_link_libraries(mobileshellstateplugin 
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        KF5::Plasma
        KF5::I18n
        KF5::Notifications
        KF5::PlasmaQuick
)

# we compiled the qml files, just install qmldir
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

ecm_generate_qmltypes(org.kde.plasma.private.mobileshell.state 1.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)
install(TARGETS mobileshellstateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/state)

