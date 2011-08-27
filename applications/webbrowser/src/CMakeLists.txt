set(active-webbrowser_SRCS
    main.cpp
    activewebbrowser.cpp
    activebrowserwindow.cpp
    kdeclarativewebview.cpp
    view.cpp
)

KDE4_ADD_EXECUTABLE(active-webbrowser ${active-webbrowser_SRCS})

target_link_libraries(active-webbrowser
    ${QT_QTWEBKIT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KDEWEBKIT_LIBRARY}
    kdeclarative
    kactivities
)

install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )
