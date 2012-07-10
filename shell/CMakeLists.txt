include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs
                    ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)

include(KDE4Defaults)

find_package(NepomukCore REQUIRED)

set(plasma-device_SRCS
    activity.cpp
    busywidget.cpp
    main.cpp
    mobcorona.cpp
    mobview.cpp
    plasmaapp.cpp
    mobdialogmanager.cpp
    mobpluginloader.cpp
    panelproxy.cpp
    panelshadows.cpp

    mobileactivitythumbnails/mobileactivitythumbnails.cpp
    mobileactivitythumbnails/imagescaler.cpp

    activityconfiguration/activityconfiguration.cpp
    activityconfiguration/backgroundlistmodel.cpp

    widgetsexplorer/mobilewidgetsexplorer.cpp
    widgetsexplorer/kcategorizeditemsviewmodels.cpp
    widgetsexplorer/plasmaappletitemmodel.cpp
)

add_kao_ontology(plasma-device_SRCS)

#set(ksmserver_xml ${KDEBASE_WORKSPACE_SOURCE_DIR}/ksmserver/org.kde.KSMServerInterface.xml)
set(ksmserver_xml ${KDE4_DBUS_INTERFACES_DIR}/org.kde.KSMServerInterface.xml)
qt4_add_dbus_interface(plasma-device_SRCS ${ksmserver_xml} ksmserver_interface)


kde4_add_kdeinit_executable(plasma-device ${plasma-device_SRCS})

target_link_libraries(kdeinit_plasma-device
        ${KDE4_PLASMA_LIBS}
        ${KDE4_KDEUI_LIBS}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${KDE4_KIO_LIBS}
        ${NEPOMUK_CORE_LIBRARY}
        ${X11_LIBRARIES}
        ${QT_QTOPENGL_LIBRARY}
        ${KACTIVITIES_LIBRARY}
)

if(X11_Xrender_FOUND)
   target_link_libraries(kdeinit_plasma-device ${X11_Xrender_LIB})
endif(X11_Xrender_FOUND)

install(TARGETS kdeinit_plasma-device DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-device ${INSTALL_TARGETS_DEFAULT_ARGS} )

#install(FILES plasma-device.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})

install(DIRECTORY widgetsexplorer/package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.widgetexplorer PATTERN .svn EXCLUDE PATTERN Messages.sh EXCLUDE)
install(DIRECTORY activityconfiguration/package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.activityconfiguration PATTERN .svn EXCLUDE PATTERN Messages.sh EXCLUDE)

