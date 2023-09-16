# SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: LGPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mobile_hotspot SOURCES hotspotsettings.cpp)
target_link_libraries(kcm_mobile_hotspot PRIVATE
    Qt::Quick
    Qt::Qml
    KF6::I18n
    KF6::CoreAddons
    KF6::KCMUtilsQuick
)

