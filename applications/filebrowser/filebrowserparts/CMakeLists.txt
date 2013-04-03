
install(DIRECTORY imageviewerpart/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.imageviewerpart)
install(FILES imageviewerpart/metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.imageviewerpart.desktop)

install(DIRECTORY audiopart/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.audiopart)
install(FILES audiopart/metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.audiopart.desktop)
