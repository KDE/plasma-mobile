# SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

kcmutils_add_qml_kcm(kcm_androidintegration SOURCES androidintegration.cpp)

target_link_libraries(kcm_androidintegration PRIVATE
    Qt::Core
    KF6::CoreAddons
    KF6::KCMUtils
    KF6::I18n
    KF6::KCMUtilsQuick
    Plasma::Plasma
    Plasma::PlasmaQuick
)
