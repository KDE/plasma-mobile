# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(kcm_mobileshell SOURCES kcm.cpp kcm.h INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobileshell
    Qt::Core
    KF5::CoreAddons
    KF5::KCMUtils
    KF5::I18n
    KF5::QuickAddons
)

kcmutils_generate_desktop_file(kcm_mobileshell)

kpackage_install_package(package kcm_mobileshell kcms) # Install our QML kpackage.
