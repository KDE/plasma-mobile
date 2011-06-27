project(recommendations)

install(DIRECTORY . DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.contour.recommendations PATTERN .svn EXCLUDE PATTERN CMakeLists.txt EXCLUDE)

install(FILES metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-contourrecommendations.desktop)
