# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_subdirectory(declarative)

if (BUILD_TESTING)
    add_subdirectory(autotests)
endif()

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.ScreenShot2.xml
                                 dbus/org.kde.KScreen.xml
                                 ${KWIN_VIRTUALKEYBOARD_INTERFACE})

set(mobileshell_LIB_SRCS
    displaysmodel.cpp
    mobileshellsettings.cpp
    shellutil.cpp
    kwinvirtualkeyboardinterface.cpp
    
    quicksetting.cpp
    quicksettingsmodel.cpp
    savedquicksettingsmodel.cpp
    savedquicksettings.cpp
    
    ${DBUS_SRCS}
)

add_library(mobileshell ${mobileshell_LIB_SRCS})
add_library(PM::LibMobileShell ALIAS mobileshell)

generate_export_header(mobileshell)

target_include_directories(mobileshell PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>" "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/libmobileshell>")
target_link_libraries(mobileshell
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
)

set_target_properties(mobileshell PROPERTIES
                      VERSION ${PROJECT_VERSION}
                      SOVERSION 1
                      EXPORT_NAME LibMobileShell)

install(TARGETS mobileshell EXPORT mobileshellLibraryTargets ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} )
                      
install(FILES
    displaysmodel.h
    kwinvirtualkeyboardinterface.h
    mobileshellsettings.h
    shellutil.h
    
    quicksetting.h
    quicksettingsmodel.h
    savedquicksettingsmodel.h
    savedquicksettings.h
    
    ${CMAKE_CURRENT_BINARY_DIR}/mobileshell_export.h
    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/mobileshell COMPONENT Devel
)
