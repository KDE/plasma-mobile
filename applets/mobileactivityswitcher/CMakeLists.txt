project(mobileactivityswitcher)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobileactivityswitcher PATTERN .svn EXCLUDE)

install(FILES plasma-applet-mobileactivityswitcher.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
