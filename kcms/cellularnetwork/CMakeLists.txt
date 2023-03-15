# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set (cellularnetworksettings_SRCS 
    cellularnetworksettings.cpp 
    modem.cpp
    modemdetails.cpp
    sim.cpp
    mobileproviders.cpp
    profilesettings.cpp
)

kcoreaddons_add_plugin(kcm_cellular_network SOURCES ${cellularnetworksettings_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_cellular_network
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    Qt::Xml
    KF6::Plasma
    KF6::I18n
    KF6::NetworkManagerQt
    KF6::ModemManagerQt
    KF6::QuickAddons
)

kcmutils_generate_desktop_file(kcm_cellular_network)
kpackage_install_package(package kcm_cellular_network kcms)
