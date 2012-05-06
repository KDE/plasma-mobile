# Install the packages, also make it known to the system

add_subdirectory(time)
add_subdirectory(locale)

# Web
install(DIRECTORY web/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.web)
install(FILES web/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.web.desktop)

#Power
install(DIRECTORY powermanagement/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.powermanagement)
install(FILES powermanagement/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.powermanagement.desktop)

# ConfigTest
#install(DIRECTORY configtest/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.configtest)
#install(FILES configtest/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.configtest.desktop)
