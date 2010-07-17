if(NOT WIN32)
add_subdirectory(mobiledesktop)
add_subdirectory(mobilelauncher)
add_subdirectory(mobilesystemtraypanel)
install(DIRECTORY homescreen
                  DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile/containments
                  PATTERN .svn EXCLUDE)
endif(NOT WIN32)
