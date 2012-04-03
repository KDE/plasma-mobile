
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

add_subdirectory(src)
#install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )

# QML-only thing
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.filebrowser)

install(DIRECTORY imageviewerpart/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.imageviewerpart)

install(FILES imageviewerpart/metadata.desktop
        DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.imageviewerpart.desktop)

install(FILES
   plasma-filebrowserpart.desktop
   DESTINATION ${SERVICETYPES_INSTALL_DIR})

install(FILES active-filebrowser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES active-imageviewer.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

