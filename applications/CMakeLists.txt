#add_subdirectory(common)

#add_subdirectory(about)
add_subdirectory(settings)
if (${KF5Baloo_FOUND})
    add_subdirectory(filebrowser)
endif()
add_subdirectory(plasma-app)

plasma_install_package(samegame org.kde.plasma.samegame packages package)
install(FILES samegame/plasma-samegame.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
add_subdirectory(webbrowser)
#add_subdirectory(widgetstrip)

kpackage_install_package(camera org.kde.phone.camera genericqml)
install(FILES camera/metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.phone.camera.desktop)
