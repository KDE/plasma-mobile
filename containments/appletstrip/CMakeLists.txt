project(appletstrip)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.appletstrip PATTERN .svn EXCLUDE)

install_metadata_file(package/metadata.desktop plasma-applet-appletstrip.desktop)
