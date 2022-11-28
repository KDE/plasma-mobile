# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
                                 
set(mobileshellplugin_SRCS
    mobileshellplugin.cpp
    mobileshellsettings.cpp
    shellutil.cpp
    windowutil.cpp
    components/direction.cpp
    quicksettings/quicksetting.cpp
    quicksettings/paginatemodel.cpp
    quicksettings/quicksettingsmodel.cpp
    quicksettings/savedquicksettings.cpp
    quicksettings/savedquicksettingsmodel.cpp
    notifications/notificationthumbnailer.cpp
    notifications/notificationfilemenu.cpp
    taskswitcher/displaysmodel.cpp
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
add_library(mobileshellplugin SHARED ${mobileshellplugin_SRCS} ${RESOURCES})

target_link_libraries(mobileshellplugin 
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        Qt::Qml
        Qt::Gui
        Qt::Quick
        KF5::ConfigWidgets # for KStandardAction
        KF5::KIOGui
        KF5::Plasma
        KF5::I18n
        KF5::Notifications
        KF5::PlasmaQuick
        KF5::KIOGui
        KF5::KIOWidgets # for PreviewJob
        KF5::WaylandClient
        KF5::Service
        KF5::Package
)

# we compiled the qml files, just install qmldir
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)

ecm_generate_qmltypes(org.kde.plasma.private.mobileshell 1.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)
install(TARGETS mobileshellplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)
