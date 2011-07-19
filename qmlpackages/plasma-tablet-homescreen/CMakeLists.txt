project(plasma-tablet-homescreen)

#FIXME: will be called org.kde.active.tablet-homescreen
install(DIRECTORY . DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/plasma-tablet-homescreen PATTERN .svn EXCLUDE PATTERN CMakeLists.txt EXCLUDE)


