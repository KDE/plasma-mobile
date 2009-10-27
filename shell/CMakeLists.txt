include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/plasmagenericshell ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kephal ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


set(plasma-mobile_SRCS
    mobcorona.cpp
    mobview.cpp
    main.cpp
    plasmaapp.cpp
)

#set(ksmserver_xml ${KDEBASE_WORKSPACE_SOURCE_DIR}/ksmserver/org.kde.KSMServerInterface.xml)
#qt4_add_dbus_interface(plasma-mobile_SRCS ${ksmserver_xml} ksmserver_interface)

kde4_add_kdeinit_executable(plasma-mobile ${plasma-mobile_SRCS})

target_link_libraries(kdeinit_plasma-mobile ${KDE4_PLASMA_LIBS} kworkspace ${KDE4_KNEWSTUFF2_LIBS} ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} kephal plasmagenericshell)
if(X11_Xrender_FOUND)
   target_link_libraries(kdeinit_plasma-mobile ${X11_Xrender_LIB})
endif(X11_Xrender_FOUND)

install(TARGETS kdeinit_plasma-mobile DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-mobile ${INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES plasma-default-layoutrc DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile/)
#install(FILES plasma-mobile.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})

