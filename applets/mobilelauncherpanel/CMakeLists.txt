project(mobilelauncherpanel)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobilelauncherpanel PATTERN .svn EXCLUDE)

install(FILES plasma-applet-mobilelauncherpanel.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
