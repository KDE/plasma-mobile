# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(kded_plasma_mobile_start_SRCS
    start.cpp
)

kcoreaddons_add_plugin(kded_plasma_mobile_start SOURCES ${kded_plasma_mobile_start_SRCS} INSTALL_NAMESPACE "kf6/kded")

target_link_libraries(kded_plasma_mobile_start PRIVATE
    Qt::Core
    KF6::DBusAddons
    KF6::KIOGui
    KF6::JobWidgets
    KF6::Package
)

