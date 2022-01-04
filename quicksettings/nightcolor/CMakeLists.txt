# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set_source_files_properties(${KWIN_COLORCORRECT_INTERFACE} PROPERTIES NO_NAMESPACE TRUE)
qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_COLORCORRECT_INTERFACE})

set(nightcolorplugin_SRCS
    nightcolorplugin.cpp
    nightcolorutil.cpp
    enum.h
    ${DBUS_SRCS}
)

kconfig_add_kcfg_files(nightcolorplugin_SRCS nightcolorsettings.kcfgc GENERATE_MOC)

add_library(nightcolorplugin ${nightcolorplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Config
    Declarative
)

target_link_libraries(nightcolorplugin
        PUBLIC
            Qt::Core
        PRIVATE
            Qt::DBus
            KF5::CoreAddons
            KF5::QuickAddons
            KF5::ConfigCore
            KF5::ConfigGui
    )

set_property(TARGET nightcolorplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/nightcolor)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/nightcolor)

install(TARGETS nightcolorplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/nightcolor)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/nightcolor)

plasma_install_package(package org.kde.plasma.nightcolor quicksettings)
