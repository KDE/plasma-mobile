
install(FILES colors metadata.desktop DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/)

FILE(GLOB widgets widgets/*.svgz)
install( FILES ${widgets} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/widgets/ )

FILE(GLOB dialogs dialogs/*.svgz)
install( FILES ${dialogs} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/dialogs/ )

FILE(GLOB icons icons/*.svgz)
install( FILES ${icons} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/icons/ )

FILE(GLOB toolbar-icons toolbar-icons/*.svgz)
install( FILES ${toolbar-icons} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/toolbar-icons/ )

FILE(GLOB appbackgrounds appbackgrounds/*.png)
install( FILES ${appbackgrounds} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/appbackgrounds/ )

