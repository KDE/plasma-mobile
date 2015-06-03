
add_subdirectory(src)
#install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )

# QML-only thing
plasma_install_package(package org.kde.plasma.active.filebrowser)

install(FILES plasma-filebrowserpart.desktop DESTINATION ${SERVICETYPES_INSTALL_DIR})
install(FILES browse-files.desktop DESTINATION ${DATA_INSTALL_DIR}/solid/actions/)

install( PROGRAMS active-filebrowser.desktop  DESTINATION  ${XDG_APPS_INSTALL_DIR} )
install( PROGRAMS active-imageviewer.desktop  DESTINATION  ${XDG_APPS_INSTALL_DIR} )

add_subdirectory(icons)
add_subdirectory(filebrowserparts)
