
install(FILES colors metadata.desktop DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/)

FILE(GLOB widgets widgets/*.svgz)
install( FILES ${widgets} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/widgets/ )
FILE(GLOB dialogs dialogs/*.svgz)
install( FILES ${dialogs} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/dialogs/ )
FILE(GLOB icons icons/*.svgz)
install( FILES ${icons} DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/icons/ )

install(DIRECTORY wallpapers/HorosGreen DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/oxygen-mobile/wallpapers PATTERN .svn EXCLUDE)

