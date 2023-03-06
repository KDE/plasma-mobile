# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(kwin4_effect_mobiletaskswitcher INSTALL_NAMESPACE "kwin/effects/plugins")
target_sources(kwin4_effect_mobiletaskswitcher PRIVATE
    main.cpp
    mobiletaskswitchereffect.cpp
)
install(FILES metadata.json DESTINATION ${KDE_INSTALL_DATADIR}/kwin/builtin-effects/kwin4_effect_mobiletaskswitcher/)

target_link_libraries(kwin4_effect_mobiletaskswitcher
    KF6::ConfigGui
    KF6::GlobalAccel
    KF6::I18n
    KF6::CoreAddons
    KF6::WindowSystem

    Qt::Quick
    Qt::Core

    KWinEffects::kwineffects
)

# install(TARGETS kwin4_effect_taskswitcher DESTINATION ${PLUGIN_INSTALL_DIR}/kwin/effects/plugins)
install(DIRECTORY qml DESTINATION ${KDE_INSTALL_DATADIR}/kwin/effects/mobiletaskswitcher)
