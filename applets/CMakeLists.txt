
if (LibKScreen_FOUND AND QTMOBILITY_FOUND AND X11_Xinput_FOUND)
installPackage(orientation org.kde.active.orientation)
endif()
installPackage(resourcelist org.kde.resourcelist)

add_subdirectory(alarms)
add_subdirectory(locationchooser)
