# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mobile_power\")

add_library(kcm_mobile_power MODULE 
    mobilepower.cpp
    batterymodel.cpp
    statisticsprovider.cpp
)

target_link_libraries(kcm_mobile_power
    Qt::DBus
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::QuickAddons
    KF6::ConfigCore
    KF6::Solid
)

install(TARGETS kcm_mobile_power DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)

kpackage_install_package(package kcm_mobile_power kcms)
