# SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_quicksetting(org.kde.plasma.quicksetting.kscreenosd
    CPP_SOURCES
        kscreenosdutil.cpp
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.kscreenosd PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::Screen
)
