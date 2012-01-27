
install(FILES colors metadata.desktop DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/)

FILE(GLOB widgets widgets/*.svgz)
install( FILES ${widgets} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/widgets/ )
FILE(GLOB dialogs dialogs/*.svgz)
install( FILES ${dialogs} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/dialogs/ )
FILE(GLOB icons icons/*.svgz)
install( FILES ${icons} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/icons/ )
FILE(GLOB toolbar-icons toolbar-icons/*.svgz)
install( FILES ${toolbar-icons} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/toolbar-icons/ )
FILE(GLOB appbackgrounds appbackgrounds/*.png)
install( FILES ${appbackgrounds} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/appbackgrounds/ )

# Install wallpaper globally, so it can be found from the config
#install(DIRECTORY wallpapers/HorosGreen DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/wallpapers PATTERN .svn EXCLUDE)
install(DIRECTORY wallpapers/HorosGreen DESTINATION ${WALLPAPER_INSTALL_DIR} PATTERN .svn EXCLUDE)

