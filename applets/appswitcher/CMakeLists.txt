project(plasma-appswitcher)


set(appswitcher_SRCS appswitcher.cpp)


kde4_add_plugin(plasma_applet_appswitcher ${appswitcher_SRCS})
target_link_libraries(plasma_applet_appswitcher
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS})

install(TARGETS plasma_applet_appswitcher
        DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-applet-appswitcher.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
