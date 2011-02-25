project(favorites)

install(DIRECTORY package/
        DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.favorites
        PATTERN .svn EXCLUDE)

install(FILES plasma-applet-favorites.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
