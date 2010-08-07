 
install(DIRECTORY mobile-homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile
                  PATTERN .svn EXCLUDE)

install(DIRECTORY tablet-homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile
                  PATTERN .svn EXCLUDE)
