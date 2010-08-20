project(news)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.fakecontactlist-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-fakecontactlist-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
