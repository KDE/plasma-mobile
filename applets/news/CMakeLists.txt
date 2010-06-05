project(news)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/news-qml PATTERN .svn EXCLUDE)

install(FILES plasma-applet-news-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
