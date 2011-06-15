project(qtwebbrowser)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/qtwebbrowser PATTERN .svn EXCLUDE)

install(FILES plasma-applet-qtwebbrowser.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})

install(FILES active-web-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

