
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} ../../common)

set(active-filebrowser_SRCS
    main.cpp
    filebrowser.cpp

    ../../common/dataenginebindings.cpp
    ../../common/kdeclarativeview.cpp
    ../../common/kdeclarativemainwindow.cpp
)

KDE4_ADD_EXECUTABLE(active-filebrowser ${active-filebrowser_SRCS})

target_link_libraries(active-filebrowser
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
)

install(TARGETS active-filebrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )

