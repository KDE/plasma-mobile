# SPDX-FileCopyrightText: 2019 Jonah Brüchert <jbb@kaidan.im>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

kcmutils_add_qml_kcm(kcm_mobile_info)

target_sources(kcm_mobile_info PRIVATE
    info.cpp
    distroinfo.cpp
    softwareinfo.cpp
    hardwareinfo.cpp
)
target_link_libraries(kcm_mobile_info PRIVATE
    Qt::Core
    Qt::Gui
    KF6::CoreAddons
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    KF6::Solid
)

