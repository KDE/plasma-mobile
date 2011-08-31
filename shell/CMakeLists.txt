include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs 
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)

include(KDE4Defaults)


set(plasma-active_SRCS
    activity.cpp
    cachingeffect.cpp
    main.cpp
    mobcorona.cpp
    mobview.cpp
    plasmaapp.cpp
    mobdialogmanager.cpp
    mobpluginloader.cpp
    declarativepanel.cpp

    mobileactivitythumbnails/mobileactivitythumbnails.cpp

    activityconfiguration/activityconfiguration.cpp
    activityconfiguration/backgroundlistmodel.cpp

    widgetsexplorer/mobilewidgetsexplorer.cpp
    widgetsexplorer/kcategorizeditemsviewmodels.cpp
    widgetsexplorer/plasmaappletitemmodel.cpp
)

#set(ksmserver_xml ${KDEBASE_WORKSPACE_SOURCE_DIR}/ksmserver/org.kde.KSMServerInterface.xml)
set(ksmserver_xml ${KDE4_DBUS_INTERFACES_DIR}/org.kde.KSMServerInterface.xml)
qt4_add_dbus_interface(plasma-active_SRCS ${ksmserver_xml} ksmserver_interface)


kde4_add_kdeinit_executable(plasma-active ${plasma-active_SRCS})

target_link_libraries(kdeinit_plasma-active ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS} ${QT_QTDECLARATIVE_LIBRARY} 
                      ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${QT_QTOPENGL_LIBRARY} kactivities)
if(X11_Xrender_FOUND)
   target_link_libraries(kdeinit_plasma-active ${X11_Xrender_LIB})
endif(X11_Xrender_FOUND)

install(TARGETS kdeinit_plasma-active DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-active ${INSTALL_TARGETS_DEFAULT_ARGS} )

#install(FILES plasma-active.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})

install(DIRECTORY widgetsexplorer/qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma-active/mobilewidgetsexplorer PATTERN .svn EXCLUDE)
install(DIRECTORY activityconfiguration/qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma-active/activityconfiguration PATTERN .svn EXCLUDE)
