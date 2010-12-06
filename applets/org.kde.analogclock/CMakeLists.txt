project(analogclock)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.analogclock PATTERN .svn EXCLUDE)

install(FILES plasma-applet-analog-clock.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
