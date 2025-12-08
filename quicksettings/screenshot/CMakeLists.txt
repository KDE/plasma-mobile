# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_org.kde.plasma.quicksetting.screenshot\")

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.ScreenShot2.xml)
add_quicksetting(org.kde.plasma.quicksetting.screenshot
    CPP_SOURCES
        ${DBUS_SRCS}
        screenshotutil.cpp
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.screenshot PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
)

install(FILES plasma_mobile_quicksetting_screenshot.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})
