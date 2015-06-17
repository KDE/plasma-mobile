
kpackage_install_package(package org.kde.phone.dialer genericqml)
install(FILES package/metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.phone.dialer.desktop)

add_subdirectory(src)
add_subdirectory(plugin)
