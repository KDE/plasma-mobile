# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

function(add_quicksetting id)
      set(oneValueArgs)
      set(multiValueArgs QML_SOURCES CPP_SOURCES RESOURCES QML_ARGS)
      cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

      # not using MODULE because of https://bugreports.qt.io/browse/QTBUG-117159
      add_library(${id} SHARED)

      set_target_properties(${id} PROPERTIES PREFIX "")

      include(ECMQmlModule)
      ecm_add_qml_module(${id} URI "plasma.mobile.quicksettings.${id}" QT_NO_PLUGIN ${ARGS_QML_ARGS})

      ecm_target_qml_sources(${id} SOURCES ${ARGS_QML_SOURCES} RESOURCES ${ARGS_RESOURCES})

      set_target_properties(${id} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/plasma/mobile/quicksettings")

      string(REPLACE "." "_" CLASS_NAME ${id})
      string(REPLACE "-" "_" CLASS_NAME ${CLASS_NAME})

      set(PLUGIN_SRC
"
#include <KPluginFactory>
#include <QObject>

class ${CLASS_NAME}_Plugin : public QObject {
   Q_OBJECT
public:
   ${CLASS_NAME}_Plugin(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
      : QObject(parent) {}
}\;

K_PLUGIN_CLASS_WITH_JSON(${CLASS_NAME}_Plugin, \"metadata.json\")

#include \"${id}.moc\"
")
      file(GENERATE OUTPUT ${id}.cpp CONTENT ${PLUGIN_SRC})
      target_sources(${id} PRIVATE ${id}.cpp)
      target_link_libraries(${id} PRIVATE KF6::CoreAddons)
      target_sources(${id} PRIVATE ${ARGS_CPP_SOURCES})
      install(TARGETS ${id} DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/mobile/quicksettings)
endfunction()

add_subdirectory(airplanemode)
add_subdirectory(audio)
add_subdirectory(battery)

plasma_install_package(bluetooth org.kde.plasma.quicksetting.bluetooth quicksettings)
plasma_install_package(caffeine org.kde.plasma.quicksetting.caffeine quicksettings)
plasma_install_package(docked org.kde.plasma.quicksetting.docked quicksettings)
plasma_install_package(donotdisturb org.kde.plasma.quicksetting.donotdisturb quicksettings)
plasma_install_package(autohidepanels org.kde.plasma.quicksetting.autohidepanels quicksettings)
plasma_install_package(keyboardtoggle org.kde.plasma.quicksetting.keyboardtoggle quicksettings)
plasma_install_package(kscreenosd org.kde.plasma.quicksetting.kscreenosd quicksettings)
plasma_install_package(mobiledata org.kde.plasma.quicksetting.mobiledata quicksettings)
plasma_install_package(settingsapp org.kde.plasma.quicksetting.settingsapp quicksettings)
plasma_install_package(waydroid org.kde.plasma.quicksetting.waydroid quicksettings)
plasma_install_package(wifi org.kde.plasma.quicksetting.wifi quicksettings)
plasma_install_package(hotspot org.kde.plasma.quicksetting.hotspot quicksettings)
add_subdirectory(flashlight)
add_subdirectory(kscreenosd)
add_subdirectory(nightcolor)
add_subdirectory(powermenu)
# TODO: Disable screen recording quick setting, as it does not work properly
add_subdirectory(record)
add_subdirectory(screenshot)
add_subdirectory(screenrotation)
