
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

add_subdirectory(src)
#install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )

# QML-only thing
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.webbrowser)
install(FILES active-web-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

add_subdirectory(icons)