# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_mobileshell SOURCES kcm.cpp)

target_link_libraries(kcm_mobileshell PRIVATE
    Qt::Core
    KF6::CoreAddons
    KF6::KCMUtils
    KF6::I18n
    KF6::KCMUtilsQuick
)

