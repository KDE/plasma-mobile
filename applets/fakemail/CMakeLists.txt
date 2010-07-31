project(fakemail)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.fakemail-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-fakemail-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
