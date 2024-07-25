# SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(plasma-mobile-notificationtest_SRCS
    main.cpp
    tests.cpp
    utils.h
)

add_executable(plasma-mobile-notificationtest ${plasma-mobile-notificationtest_SRCS} ${RESOURCES})
target_link_libraries(plasma-mobile-notificationtest
    Qt::Qml
    Qt::Gui
    Qt::Widgets
    Qt::Quick
    KF6::I18n
    KF6::ConfigCore
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::Notifications
    KF6::JobWidgets
)

target_include_directories(plasma-mobile-notificationtest PRIVATE ${CMAKE_BINARY_DIR})
install(TARGETS plasma-mobile-notificationtest ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES plasma_mobile_notificationtest.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})
