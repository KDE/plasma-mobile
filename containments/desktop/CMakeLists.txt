set(desktop_SRCS
    desktop.cpp
    )

kde4_add_plugin(plasma_containment_desktop ${desktop_SRCS})
target_link_libraries(plasma_containment_desktop ${KDE4_PLASMA_LIBS} ${KDE4_KIO_LIBS} ${KDE4_KFILE_LIBS})

install(TARGETS plasma_containment_desktop DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-containment-desktop.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(FILES plasma_desktop_containment.kwinrules DESTINATION ${DATA_INSTALL_DIR}/kwin/default_rules)
