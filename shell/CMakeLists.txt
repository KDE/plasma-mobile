include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs 
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)

include(KDE4Defaults)

add_subdirectory(data)
add_subdirectory(mobiletoolbox)

set(plasma-mobile_SRCS
    main.cpp
    mobcorona.cpp
    mobview.cpp
    plasmaapp.cpp
    mobdialogmanager.cpp
    inputcontext.cpp
    
    widgetsexplorer/mobilewidgetsexplorer.cpp
    widgetsexplorer/kcategorizeditemsviewmodels.cpp
    widgetsexplorer/plasmaappletitemmodel.cpp
)

set(PLASMA_BINDINGS
  plasma_bindings
)

#set(ksmserver_xml ${KDEBASE_WORKSPACE_SOURCE_DIR}/ksmserver/org.kde.KSMServerInterface.xml)
set(ksmserver_xml ${KDE4_DBUS_INTERFACES_DIR}/org.kde.KSMServerInterface.xml)
qt4_add_dbus_interface(plasma-mobile_SRCS ${ksmserver_xml} ksmserver_interface)

qt4_add_dbus_interface(plasma-mobile_SRCS org.kde.PlasmaKeyboardShell.xml keyboard_interface)

kde4_add_kdeinit_executable(plasma-mobile ${plasma-mobile_SRCS})

target_link_libraries(kdeinit_plasma-mobile ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS} ${QT_QTDECLARATIVE_LIBRARY} 
                      ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${PLASMA_BINDINGS} ${QT_QTOPENGL_LIBRARY})
if(X11_Xrender_FOUND)
   target_link_libraries(kdeinit_plasma-mobile ${X11_Xrender_LIB})
endif(X11_Xrender_FOUND)

install(TARGETS kdeinit_plasma-mobile DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-mobile ${INSTALL_TARGETS_DEFAULT_ARGS} )

#install(FILES plasma-mobile.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})

install(DIRECTORY widgetsexplorer/qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile/mobilewidgetsexplorer PATTERN .svn EXCLUDE)
