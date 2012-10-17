include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


ADD_DEFINITIONS(-DNO_ACTIVITIES)

set(plasma-widgetstrip_SRCS
    singleview.cpp
    main.cpp
    plasmaapp.cpp
    stripcorona.cpp

    ${CMAKE_SOURCE_DIR}/shell/activityconfiguration/activityconfiguration.cpp
    ${CMAKE_SOURCE_DIR}/shell/activityconfiguration/backgroundlistmodel.cpp

    ${CMAKE_SOURCE_DIR}/shell/widgetsexplorer/mobilewidgetsexplorer.cpp
    ${CMAKE_SOURCE_DIR}/shell/widgetsexplorer/kcategorizeditemsviewmodels.cpp
    ${CMAKE_SOURCE_DIR}/shell/widgetsexplorer/plasmaappletitemmodel.cpp

    ${appletbrowserdialog_SRCS}
)


kde4_add_kdeinit_executable(plasma-widgetstrip ${plasma-widgetstrip_SRCS})

target_link_libraries(kdeinit_plasma-widgetstrip ${KDE4_PLASMA_LIBS} ${KDE4WORKSPACE_KWORKSPACE_LIBRARY} ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} ${QT_QTOPENGL_LIBRARY}  ${QT_QTDECLARATIVE_LIBRARY} )

install(DIRECTORY widgetsexplorer/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.widgetsexplorer PATTERN .svn EXCLUDE PATTERN Messages.sh EXCLUDE)
install(TARGETS kdeinit_plasma-widgetstrip DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-widgetstrip ${INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES widget-strip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES plasma-default-layoutrc DESTINATION ${DATA_INSTALL_DIR}/plasma-widgetstrip)
