# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mobile_power\")

set(kcm_mobile_power_SRCS
    mobilepower.cpp
    batterymodel.cpp
    statisticsprovider.cpp
)

kcoreaddons_add_plugin(kcm_mobile_power SOURCES ${kcm_mobile_power_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobile_power
    Qt::DBus
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::QuickAddons
    KF6::ConfigCore
    KF6::Solid
)

kcmutils_generate_desktop_file(kcm_mobile_power)
kpackage_install_package(package kcm_mobile_power kcms)
