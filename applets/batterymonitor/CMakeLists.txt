project(batterymonitor)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.batterymonitor PATTERN .svn EXCLUDE)

install(FILES plasma-applet-batterymonitor.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
