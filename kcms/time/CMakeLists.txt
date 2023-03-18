# SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
# SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(timesettings_SRCS
    timesettings.cpp
    timezonemodel.cpp
    timezonesi18n.cpp
)

qt_add_dbus_interface(timesettings_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/timedated1.xml timedated_interface)

kcoreaddons_add_plugin(kcm_mobile_time SOURCES ${timesettings_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobile_time
    Qt::Quick
    Qt::Qml
    Qt::DBus
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    KF6::I18n
)

# Time and Date

kcmutils_generate_desktop_file(kcm_mobile_time)
kpackage_install_package(package kcm_mobile_time kcms)
