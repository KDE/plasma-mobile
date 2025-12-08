# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_quicksetting(org.kde.plasma.quicksetting.record
    CPP_SOURCES
        recordutil.cpp
    QML_SOURCES
        qml/main.qml
)

target_link_libraries(org.kde.plasma.quicksetting.record PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    K::KPipeWire
    K::KPipeWireRecord
)

install(FILES plasma_mobile_quicksetting_record.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})
