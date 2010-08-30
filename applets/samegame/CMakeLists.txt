project(samegame)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.samegame-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-samegame-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
