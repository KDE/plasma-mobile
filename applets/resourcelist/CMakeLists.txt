project(favorites)

install(DIRECTORY package/
        DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.resourcelist
        PATTERN .svn EXCLUDE)

install(FILES plasma-applet-resourcelist.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
