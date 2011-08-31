project(plasma-mobiletoolbox)


set(mobiletoolbox_SRCS mobiletoolbox.cpp)


kde4_add_plugin(plasma_toolbox_mobiletoolbox ${mobiletoolbox_SRCS})
target_link_libraries(plasma_toolbox_mobiletoolbox 
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS})

install(TARGETS plasma_toolbox_mobiletoolbox
        DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-toolbox-mobiletoolbox.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})
