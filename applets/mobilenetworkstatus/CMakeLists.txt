project(mobilenetworkstatus)

install(
    DIRECTORY package/
    DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.mobilenetworkstatus
    PATTERN .svn EXCLUDE
)

install(
    FILES
        plasma-applet-mobilenetworkstatus.desktop
    DESTINATION ${SERVICES_INSTALL_DIR}
)
