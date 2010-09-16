project(news)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.nowplaying-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-nowplaying-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
