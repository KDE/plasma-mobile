
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(active-imageviewer_SRCS
    dataenginebindings.cpp
    main.cpp
    imageviewer.cpp
    view.cpp
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

# QML-only thing
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.imageviewer PATTERN .svn EXCLUDE)
install(FILES active-image-viewer.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

add_subdirectory(icons)
