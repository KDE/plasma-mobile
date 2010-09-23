project(news)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.addons-example-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-addons-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
