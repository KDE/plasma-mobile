project(mobilesystemtray)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobilesystemtray PATTERN .svn EXCLUDE)

install(FILES plasma-applet-mobilesystemtray.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
