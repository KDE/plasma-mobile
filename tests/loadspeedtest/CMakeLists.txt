# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(plasma-mobile-loadspeedtest_SRCS
    main.cpp
    quicksettingstest.cpp
)

add_executable(plasma-mobile-loadspeedtest ${plasma-mobile-loadspeedtest_SRCS} ${RESOURCES})
target_link_libraries(plasma-mobile-loadspeedtest
    Qt::Qml
    Qt::Gui
    Qt::Widgets
    Qt::Quick
    KF6::I18n
    KF6::ConfigCore
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::Package
)

target_include_directories(plasma-mobile-loadspeedtest PRIVATE ${CMAKE_BINARY_DIR})
install(TARGETS plasma-mobile-loadspeedtest ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
