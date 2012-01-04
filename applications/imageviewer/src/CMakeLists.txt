
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(active-imageviewer_SRCS
    dataenginebindings.cpp
    main.cpp
    dirmodel.cpp
    imageviewer.cpp
    view.cpp
    kdeclarativeview.cpp
)

KDE4_ADD_EXECUTABLE(active-imageviewer ${active-imageviewer_SRCS})

target_link_libraries(active-imageviewer
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
)

install(TARGETS active-imageviewer ${INSTALL_TARGETS_DEFAULT_ARGS} )

