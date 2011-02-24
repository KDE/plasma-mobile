project(bookmarks)

install(DIRECTORY package/
        DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.bookmarks
        PATTERN .svn EXCLUDE)

install(FILES plasma-applet-bookmarks.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
