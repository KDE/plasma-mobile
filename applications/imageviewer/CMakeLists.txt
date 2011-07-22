
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(imagevieweractive_SRCS
    main.cpp
    imageviewer.cpp
    view.cpp
)

KDE4_ADD_EXECUTABLE(imageviewer-active ${imagevieweractive_SRCS})

target_link_libraries(imageviewer-active
    ${QT_QTDECLARATIVE_LIBRARY} 
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
)

install( TARGETS imageviewer-active ${INSTALL_TARGETS_DEFAULT_ARGS} )

# QML-only thing
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.imageviewer PATTERN .svn EXCLUDE)
install(FILES active-image-viewer.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
