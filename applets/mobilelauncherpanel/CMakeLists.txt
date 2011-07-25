project(mobilelauncherpanel)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.active.launcherpanel)

install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-org.kde.active.launcherpanel.desktop)
