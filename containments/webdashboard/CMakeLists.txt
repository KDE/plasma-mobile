project(webdashboard)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.webdashboard PATTERN .svn EXCLUDE)

install(FILES plasma-applet-webdashboard.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
