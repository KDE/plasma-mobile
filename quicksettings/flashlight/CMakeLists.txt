# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_quicksetting(org.kde.plasma.quicksetting.flashlight
    CPP_SOURCES
        flashlightutil.cpp
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.flashlight PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::AuthCore
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    udev
)

add_subdirectory(kauth)
