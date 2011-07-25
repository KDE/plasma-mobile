MACRO(installPackage dir component)
install(DIRECTORY ${dir}/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/${component})
install(FILES ${dir}/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-${component}.desktop)
ENDMACRO(installPackage)

installPackage(active-welcome org.kde.active.welcome)
installPackage(launcherpanel org.kde.active.launcherpanel)
installPackage(systemtray org.kde.active.systemtray)
installPackage(notifications org.kde.active.notifications)
installPackage(powerbutton org.kde.active.powerbutton)
installPackage(resourcelist org.kde.resourcelist)

add_subdirectory(appswitcher)
add_subdirectory(windowstrip)
