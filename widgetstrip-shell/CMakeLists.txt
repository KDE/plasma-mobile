include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


ADD_DEFINITIONS(-DNO_ACTIVITIES)

set(appletstrip-shell_SRCS
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


kde4_add_kdeinit_executable(appletstrip-shell ${appletstrip-shell_SRCS})

target_link_libraries(kdeinit_appletstrip-shell ${KDE4_PLASMA_LIBS} kworkspace ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} ${QT_QTOPENGL_LIBRARY}  ${QT_QTDECLARATIVE_LIBRARY} )


install(TARGETS kdeinit_appletstrip-shell DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS appletstrip-shell ${INSTALL_TARGETS_DEFAULT_ARGS})

