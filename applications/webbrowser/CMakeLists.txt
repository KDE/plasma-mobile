project(plasma-mobile-browser)


find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui WebEngine)

set (QT_MIN_VERSION "5.4.0")

find_package(KF5KIO REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
#########################################################################


add_subdirectory(src)
add_subdirectory(autotests)

install( PROGRAMS angelfish.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} )

plasma_install_package(package org.kde.plasma.satellite.angelfish packages package)
# install(FILES plasma-mobile-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})


