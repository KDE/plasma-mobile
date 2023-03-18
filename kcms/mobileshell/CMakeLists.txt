# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(kcm_mobileshell SOURCES kcm.cpp INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobileshell
    Qt::Core
    KF6::CoreAddons
    KF6::KCMUtils
    KF6::I18n
    KF6::KCMUtilsQuick
)

kcmutils_generate_desktop_file(kcm_mobileshell)

kpackage_install_package(package kcm_mobileshell kcms) # Install our QML kpackage.
