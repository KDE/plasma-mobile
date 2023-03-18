# SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

set(info_SRCS # Specify source files for the library
    info.cpp
    distroinfo.cpp
    softwareinfo.cpp
    hardwareinfo.cpp
)

kcoreaddons_add_plugin(kcm_mobile_info SOURCES ${info_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobile_info
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    KF6::Solid
)

kpackage_install_package(package kcm_mobile_info kcms)
kcmutils_generate_desktop_file(kcm_mobile_info)

