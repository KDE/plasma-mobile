# SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(ppc-mmqmlplugin URI org.kde.plasma.mm GENERATE_PLUGIN_SOURCE)
target_sources(ppc-mmqmlplugin PRIVATE
    signalindicator.cpp
    profilesettings.cpp
)


target_link_libraries(ppc-mmqmlplugin PRIVATE
    Qt::Qml
    KF6::ModemManagerQt
    KF6::NetworkManagerQt
    KF6::CoreAddons
    KF6::I18n
    QCoro::DBus
)


ecm_finalize_qml_module(ppc-mmqmlplugin)
