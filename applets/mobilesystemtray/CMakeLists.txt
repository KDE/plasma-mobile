project(mobilesystemtray)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobilesystemtray PATTERN .svn EXCLUDE)

install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-mobilesystemtray.desktop)
