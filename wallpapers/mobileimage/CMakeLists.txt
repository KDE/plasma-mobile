project(plasma-wallpaper-mobileimage)

set(mobileimage_SRCS
    mobileimage.cpp
    backgroundlistmodel.cpp
)

kde4_add_plugin(plasma_wallpaper_mobileimage ${mobileimage_SRCS})
target_link_libraries(plasma_wallpaper_mobileimage ${KDE4_PLASMA_LIBS} ${KDE4_KIO_LIBS} ${KDE4_KFILE_LIBS} ${KDE4_KNEWSTUFF3_LIBS})

install(TARGETS plasma_wallpaper_mobileimage DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-wallpaper-mobileimage.desktop DESTINATION ${SERVICES_INSTALL_DIR})

#install(FILES wallpaper.knsrc DESTINATION ${CONFIG_INSTALL_DIR})
