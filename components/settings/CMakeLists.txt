project(settings)

set(settings_SRCS
    settingsplugin.cpp
    settingsmodule.cpp
    settingsmodulesmodel.cpp
    settingscomponent.cpp
    configgroup.cpp
    )

add_library(settingsplugin SHARED ${settings_SRCS})
target_link_libraries(settingsplugin
        Qt5::Core
        Qt5::Qml
        Qt5::Quick
        KF5::Plasma
        )

install(TARGETS settingsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/active/settings)
install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/active/settings)
install(FILES SettingsItem.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/active/settings)

