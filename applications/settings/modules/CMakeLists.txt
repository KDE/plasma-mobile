
# Install the package, also make it known to the system
install(DIRECTORY time/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
install(FILES time/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.time.desktop)
