include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


set(appletstrip-shell_SRCS
    singleview.cpp
    main.cpp
    plasmaapp.cpp
    stripcorona.cpp
    ${appletbrowserdialog_SRCS}
)


kde4_add_kdeinit_executable(appletstrip-shell ${appletstrip-shell_SRCS})

target_link_libraries(kdeinit_appletstrip-shell ${KDE4_PLASMA_LIBS} kworkspace ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} )


install(TARGETS kdeinit_appletstrip-shell DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS appletstrip-shell ${INSTALL_TARGETS_DEFAULT_ARGS})

