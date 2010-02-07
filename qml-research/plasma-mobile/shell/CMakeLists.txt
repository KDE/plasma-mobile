include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs 
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/plasmagenericshell 
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kephal
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)

set(plasma-mobile_SRCS
    main.cpp
    mobcorona.cpp
    mobview.cpp
    plasmaapp.cpp
)

QT4_ADD_RESOURCES(RCS_SRCS plasma-mobile-qml.qrc)

#set(ksmserver_xml ${KDEBASE_WORKSPACE_SOURCE_DIR}/ksmserver/org.kde.KSMServerInterface.xml)
set(ksmserver_xml ${KDE4_DBUS_INTERFACES_DIR}/org.kde.KSMServerInterface.xml)
qt4_add_dbus_interface(plasma-mobile_SRCS ${ksmserver_xml} ksmserver_interface)

kde4_add_kdeinit_executable(plasma-mobile-qml ${plasma-mobile_SRCS} ${RCS_SRCS})

target_link_libraries(kdeinit_plasma-mobile-qml ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS} ${QT_QTDECLARATIVE_LIBRARY} 
                      kworkspace ${KDE4_KIO_LIBS} ${X11_LIBRARIES} kephal plasmagenericshell)
if(X11_Xrender_FOUND)
   target_link_libraries(kdeinit_plasma-mobile-qml ${X11_Xrender_LIB})
endif(X11_Xrender_FOUND)

install(TARGETS kdeinit_plasma-mobile-qml DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-mobile-qml ${INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES plasma-default-layoutrc DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile-qml/)
#install(FILES plasma-mobile-qml.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})

