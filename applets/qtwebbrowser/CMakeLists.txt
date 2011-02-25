project(qtwebbrowser)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/qtwebbrowser PATTERN .svn EXCLUDE)

install(FILES plasma-applet-qtwebbrowser.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
