project(webdashboard)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.webdashboard PATTERN .svn EXCLUDE)

install_metadata_file(package/metadata.desktop plasma-applet-webdashboard.desktop)

