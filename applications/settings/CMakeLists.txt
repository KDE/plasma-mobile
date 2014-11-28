project(active-settings)

#include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

add_subdirectory(src)
#add_subdirectory(modules)

# Install plugin definition
install(FILES active-settingsmodule.desktop DESTINATION ${SERVICETYPES_INSTALL_DIR})

# .. and finally the package with the shell
#install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings)
plasma_install_package(package org.kde.active.settings packages package)


install(FILES active-settings.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

