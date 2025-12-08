# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_quicksetting(org.kde.plasma.quicksetting.screenrotation
    CPP_SOURCES
        screenrotationutil.cpp
        ../../components/rotationplugin/sensorproxy.cpp
        ../../components/rotationplugin/sensorproxy.h
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.screenrotation PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    KF6::Screen
)
