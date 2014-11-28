# Install the packages, also make it known to the system

#add_subdirectory(development)
#add_subdirectory(time)
#add_subdirectory(locale)

# Web
#install(DIRECTORY web/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.web)
#install(FILES web/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.web.desktop)

#Power

plasma_install_package(powermanagement org.kde.active.settings.powermanagement packages package)
#install(DIRECTORY powermanagement/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.powermanagement)
#install(FILES powermanagement/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.powermanagement.desktop)

# ConfigTest
#install(DIRECTORY configtest/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.configtest)
#install(FILES configtest/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.configtest.desktop)
plasma_install_package(configtest org.kde.active.settings.configtest packages package)

