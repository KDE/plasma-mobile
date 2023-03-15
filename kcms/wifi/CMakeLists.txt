# SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>
# SPDX-License-Identifier: LGPL-2.0-or-later

project (kcm_mobile_wifi)

set (wifisettings_SRCS wifisettings.cpp)

kcoreaddons_add_plugin(kcm_mobile_wifi SOURCES ${wifisettings_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobile_wifi
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    KF6::I18n
    KF6::NetworkManagerQt
    KF6::Plasma
    KF6::QuickAddons
)

kpackage_install_package(package kcm_mobile_wifi kcms)
kcmutils_generate_desktop_file(kcm_mobile_wifi)
