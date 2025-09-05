# SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_navigation SOURCES kcm.cpp)

target_link_libraries(kcm_navigation PRIVATE
    Qt::Core
    KF6::CoreAddons
    KF6::KCMUtils
    KF6::I18n
    KF6::KCMUtilsQuick
)

