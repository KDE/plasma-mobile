project(qmlwidgets)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/qmlwidgets PATTERN .svn EXCLUDE)

install(FILES plasma-applet-qmlwidgets.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
