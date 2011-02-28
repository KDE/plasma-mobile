project(appletstrip)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.appletstrip PATTERN .svn EXCLUDE)

install(FILES plasma-applet-appletstrip.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
