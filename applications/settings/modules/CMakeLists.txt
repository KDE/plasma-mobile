# Install the packages, also make it known to the system

# Time and Date
install(DIRECTORY time/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
install(FILES time/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.time.desktop)


# Web
install(DIRECTORY web/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.web)
install(FILES web/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.web.desktop)
