project(notifications)

install(DIRECTORY package/
        DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobile.notifications
        PATTERN .svn EXCLUDE)

install(FILES plasma-applet-mobilenotifications.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
