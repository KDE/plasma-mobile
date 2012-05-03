
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} ../../common)

set(active-filebrowser_SRCS
    main.cpp
    filebrowser.cpp
)

kde4_add_kdeinit_executable(active-filebrowser ${active-filebrowser_SRCS})

#find_package(ActiveApp REQUIRED)

target_link_libraries(kdeinit_active-filebrowser
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
    activeapp
)

install(TARGETS active-filebrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )
install(TARGETS kdeinit_active-filebrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )

