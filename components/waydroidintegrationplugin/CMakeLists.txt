# SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
# SPDX-License-Identifier: BSD-2-Clause

ecm_add_qml_module(waydroidintegrationplugin URI org.kde.plasma.private.mobileshell.waydroidintegrationplugin GENERATE_PLUGIN_SOURCE)
target_sources(waydroidintegrationplugin PRIVATE waydroidstate.cpp waydroidapplication.cpp waydroidapplicationlistmodel.cpp)

target_link_libraries(waydroidintegrationplugin PRIVATE
    Qt::Gui
    Qt::Qml
    Qt::Quick
    KF6::AuthCore
    KF6::I18n
    QCoro::Core
    QCoro::Qml
)

ecm_finalize_qml_module(waydroidintegrationplugin)

ecm_qt_declare_logging_category(waydroidintegrationplugin
    HEADER waydroidintegrationplugin_debug.h
    IDENTIFIER WAYDROIDINTEGRATIONPLUGIN
    DEFAULT_SEVERITY Warning
    CATEGORY_NAME org.kde.plasma.private.mobileshell.waydroidintegrationplugin
    DESCRIPTION "Plugin to add Waydroid Integration on Plasma"
)

add_subdirectory(kauth)
