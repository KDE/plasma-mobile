project(news)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/quickdialer-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-quickdialer-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
