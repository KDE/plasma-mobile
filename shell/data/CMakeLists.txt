 
install(DIRECTORY plasma-mobile-homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile
                  PATTERN .svn EXCLUDE)

install(DIRECTORY plasma-tablet-homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile
                  PATTERN .svn EXCLUDE)

install(DIRECTORY plasma-contour-homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile
                  PATTERN .svn EXCLUDE)
