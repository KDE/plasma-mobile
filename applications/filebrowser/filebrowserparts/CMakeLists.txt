
install(DIRECTORY imageviewerpart/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.imageviewerpart)
install(FILES imageviewerpart/metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.imageviewerpart.desktop)
