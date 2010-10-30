project(knowledgebase)

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.knowledgebase PATTERN .svn EXCLUDE)

install(FILES plasma-applet-knowledgebase-qml.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
