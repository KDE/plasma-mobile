project(digital-clock)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/digital-clock-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-digital-clock-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
