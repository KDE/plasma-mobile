
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(active-videoviewer_SRCS
    dataenginebindings.cpp
    main.cpp
    videoviewer.cpp
    videowidget.cpp
    view.cpp
)

kde4_add_ui_files(
    active-videoviewer_SRCS
    videowindow.ui
)


KDE4_ADD_EXECUTABLE(active-videoviewer ${active-videoviewer_SRCS})

target_link_libraries(active-videoviewer
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_PHONON_LIBRARY}
    kdeclarative
)

install(TARGETS active-videoviewer ${INSTALL_TARGETS_DEFAULT_ARGS} )

