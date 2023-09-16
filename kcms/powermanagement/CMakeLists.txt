# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mobile_power\")

kcmutils_add_qml_kcm(kcm_mobile_power SOURCES ${kcm_mobile_power_SRCS})

target_sources(kcm_mobile_power PRIVATE
    mobilepower.cpp
    batterymodel.cpp
    statisticsprovider.cpp
)
target_link_libraries(kcm_mobile_power PRIVATE
    Qt::DBus
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    KF6::Solid
)

