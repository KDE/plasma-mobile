# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_cellular_network)

target_sources(kcm_cellular_network PRIVATE
    cellularnetworksettings.cpp 
    modem.cpp
    modemdetails.cpp
    sim.cpp
    mobileproviders.cpp
    profilesettings.cpp
)
target_link_libraries(kcm_cellular_network PRIVATE
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    Qt::Xml
    Plasma::Plasma
    KF6::I18n
    KF6::NetworkManagerQt
    KF6::ModemManagerQt
    KF6::KCMUtilsQuick
)
