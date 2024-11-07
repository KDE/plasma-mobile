# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_org.kde.plasma.mobileinitialstart\")

add_subdirectory(modules)

add_executable(plasma-mobile-initial-start
    main.cpp
    wizard.cpp
    wizard.h
    settings.cpp
    settings.h
    utils.h
    initialstartutil.cpp
    initialstartutil.h
    initialstartmodule.cpp
    initialstartmodule.h
)

qt_add_qml_module(plasma-mobile-initial-start
    URI org.kde.plasma.mobileinitialstart.initialstart
    VERSION 1.0
)

target_link_libraries(plasma-mobile-initial-start PUBLIC
    Qt::Qml
    Qt::Gui
    Qt::Widgets
    Qt::Quick
    KF6::I18n
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::Package
)

qt_target_qml_sources(plasma-mobile-initial-start
    QML_FILES
        qml/Main.qml
        qml/Wizard.qml
        qml/LandingComponent.qml
)

target_include_directories(plasma-mobile-initial-start PRIVATE ${CMAKE_BINARY_DIR})
install(TARGETS plasma-mobile-initial-start ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
