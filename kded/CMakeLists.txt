# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(kded_plasma-mobile-start INSTALL_NAMESPACE "kf${QT_MAJOR_VERSION}/kded")

target_sources(kded_plasma-mobile-start PRIVATE
    startdaemon.cpp
    settings.cpp
    config.h
    utils.h
)

target_link_libraries(kded_plasma-mobile-start PRIVATE
    Qt::Core
    KF5::DBusAddons
    KF5::ConfigWidgets
    KF5::KIOGui
    KF5::Notifications
    KF5::Package
)

