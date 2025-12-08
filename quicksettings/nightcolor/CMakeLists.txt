# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

set_source_files_properties(${KWIN_NIGHTLIGHT_INTERFACE} PROPERTIES NO_NAMESPACE TRUE)
qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_NIGHTLIGHT_INTERFACE})

kconfig_add_kcfg_files(KCONFIG_SRCS nightcolorsettings.kcfgc GENERATE_MOC)

add_quicksetting(org.kde.plasma.quicksetting.nightcolor
    CPP_SOURCES
        ${DBUS_SRCS}
        ${KCONFIG_SRCS}
        nightcolorutil.cpp
        enum.h
    QML_SOURCES
        qml/main.qml
)


target_link_libraries(org.kde.plasma.quicksetting.nightcolor PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
)
