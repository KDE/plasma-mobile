set(mobilesystemtraypanel_SRCS
    mobilesystemtraypanel.cpp
    )

kde4_add_plugin(plasma_containment_mobilesystemtraypanel ${mobilesystemtraypanel_SRCS})
target_link_libraries(plasma_containment_mobilesystemtraypanel ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY} )

#install(DIRECTORY qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile/containments/mobile-desktop PATTERN .svn EXCLUDE)
install(TARGETS plasma_containment_mobilesystemtraypanel DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-containment-mobilesystemtraypanel.desktop DESTINATION ${SERVICES_INSTALL_DIR})
