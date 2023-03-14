# SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: LGPL-2.0-or-later

set (hotspotsettings_SRCS hotspotsettings.cpp)

add_library(kcm_mobile_hotspot MODULE ${hotspotsettings_SRCS})

target_link_libraries(kcm_mobile_hotspot
    Qt::Quick
    Qt::Qml
    KF6::I18n
    KF6::CoreAddons
    KF6::QuickAddons
)

install(TARGETS kcm_mobile_hotspot DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_mobile_hotspot kcms)
kcmutils_generate_desktop_file(kcm_mobile_hotspot)
