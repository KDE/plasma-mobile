project(mobilemenu)

install(DIRECTORY . DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.contourmobilemenu PATTERN .svn EXCLUDE PATTERN CMakeLists.txt EXCLUDE)

install(FILES metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-contourmobilemenu.desktop)
