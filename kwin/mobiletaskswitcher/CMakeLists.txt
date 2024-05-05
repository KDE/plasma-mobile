# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

kcoreaddons_add_plugin(mobiletaskswitcher INSTALL_NAMESPACE "kwin/effects/plugins")
target_sources(mobiletaskswitcher PRIVATE
    main.cpp
    mobiletaskswitchereffect.cpp
    effecttouchborder.cpp
)

target_compile_definitions(mobiletaskswitcher PRIVATE QT_QML_DEBUG)

target_link_libraries(mobiletaskswitcher
    KF6::ConfigGui
    KF6::GlobalAccel
    KF6::I18n
    KF6::CoreAddons
    KF6::WindowSystem

    Qt::Quick
    Qt::Core

    KWin::kwin
)

# install(TARGETS kwin4_effect_taskswitcher DESTINATION ${PLUGIN_INSTALL_DIR}/kwin/effects/plugins)
install(DIRECTORY qml DESTINATION ${KDE_INSTALL_DATADIR}/kwin/effects/mobiletaskswitcher)
