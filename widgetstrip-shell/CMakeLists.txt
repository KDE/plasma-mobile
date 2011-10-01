include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


ADD_DEFINITIONS(-DNO_ACTIVITIES)

set(plasma-widgetstrip_SRCS
    singleview.cpp
    main.cpp
    plasmaapp.cpp
    stripcorona.cpp

    ../shell/activityconfiguration/activityconfiguration.cpp
    ../shell/activityconfiguration/backgroundlistmodel.cpp

    ../shell/widgetsexplorer/mobilewidgetsexplorer.cpp
    ../shell/widgetsexplorer/kcategorizeditemsviewmodels.cpp
    ../shell/widgetsexplorer/plasmaappletitemmodel.cpp

    ${appletbrowserdialog_SRCS}
)


kde4_add_kdeinit_executable(plasma-widgetstrip ${plasma-widgetstrip_SRCS})

target_link_libraries(kdeinit_plasma-widgetstrip ${KDE4_PLASMA_LIBS} kworkspace ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} ${QT_QTOPENGL_LIBRARY}  ${QT_QTDECLARATIVE_LIBRARY} )


install(TARGETS kdeinit_plasma-widgetstrip DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-widgetstrip ${INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES widget-strip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES plasma-default-layoutrc DESTINATION ${DATA_INSTALL_DIR}/plasma-widgetstrip)