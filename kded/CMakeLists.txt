# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(kded_plasma_mobile_start INSTALL_NAMESPACE "kf${QT_MAJOR_VERSION}/kded")

target_sources(kded_plasma_mobile_start PRIVATE
    start.cpp
)

target_link_libraries(kded_plasma_mobile_start PRIVATE
    Qt::Core
    KF6::DBusAddons
    KF6::ConfigWidgets
    KF6::KIOGui
    KF6::Notifications
    KF6::Package
)

