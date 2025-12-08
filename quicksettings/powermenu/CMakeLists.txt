# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

find_package(LibKWorkspace)

add_quicksetting(org.kde.plasma.quicksetting.powermenu
    CPP_SOURCES
        powermenuutil.cpp
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.powermenu PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    PW::KWorkspace
)
