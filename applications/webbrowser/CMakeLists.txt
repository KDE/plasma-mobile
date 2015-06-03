project(plasma-mobile-browser)

set(REQUIRED_QT_VERSION 5.2.0)

find_package(Qt5WebEngine CONFIG)
set_package_properties(Qt5WebEngine PROPERTIES
                       TYPE OPTIONAL
                      )
add_feature_info("Qt5WebEngine" Qt5WebEngine_FOUND "Required for building the Angelfish webbrowser")

set (QT_MIN_VERSION "5.4.0")

find_package(KF5KIO REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
#########################################################################

if(Qt5WebEngine_FOUND)

    add_subdirectory(src)
    add_subdirectory(autotests)

    install( PROGRAMS angelfish.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} )

    plasma_install_package(package org.kde.plasma.satellite.angelfish packages package)
    #install(FILES plasma-mobile-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

endif()

