
install(FILES colors metadata.desktop DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/)

FILE(GLOB widgets widgets/*.svgz)
install( FILES ${widgets} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/widgets/ )

install(DIRECTORY wallpapers/Universe DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/air-mobile/wallpapers PATTERN .svn EXCLUDE)

#TODO: make possible to load other wallpapers fro the theme package
install(DIRECTORY wallpapers/Fiber DESTINATION ${WALLPAPER_INSTALL_DIR} PATTERN .svn EXCLUDE)

