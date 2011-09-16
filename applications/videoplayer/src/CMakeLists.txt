
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(active-videoplayer_SRCS
    dataenginebindings.cpp
    main.cpp
    videoplayer.cpp
    videowidget.cpp
    view.cpp
)

kde4_add_ui_files(
    active-videoplayer_SRCS
    videowindow.ui
)

qt4_add_dbus_adaptor(
    active-videoplayer_SRCS
    org.mpris.MediaPlayer2.Player.xml
    videowidget.h VideoWidget
)

KDE4_ADD_EXECUTABLE(active-videoplayer ${active-videoplayer_SRCS})

target_link_libraries(active-videoplayer
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_PHONON_LIBRARY}
    kdeclarative
)

install(TARGETS active-videoplayer ${INSTALL_TARGETS_DEFAULT_ARGS} )

