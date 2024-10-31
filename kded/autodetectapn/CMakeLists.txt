# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later OR LicenseRef-KDE-Accepted-GPL

set(kded_plasma_mobile_autodetect_apn_SRCS
    autodetectapn.cpp
)

kcoreaddons_add_plugin(kded_plasma_mobile_autodetect_apn SOURCES ${kded_plasma_mobile_autodetect_apn_SRCS} INSTALL_NAMESPACE "kf6/kded")

install(FILES android/apns-full-conf.xml DESTINATION ${KDE_INSTALL_DATADIR}/plasma-mobile-apn-info)

target_link_libraries(kded_plasma_mobile_autodetect_apn PRIVATE
    Qt::Core
    Qt::Xml
    KF6::DBusAddons
    KF6::KIOGui
    KF6::JobWidgets
    KF6::Package
    KF6::NetworkManagerQt
    KF6::ModemManagerQt
    QCoro::DBus
)
