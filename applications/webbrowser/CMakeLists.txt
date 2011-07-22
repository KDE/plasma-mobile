
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

set(rekonqactive_SRCS
    main.cpp
    activebrowserwindow.cpp
    view.cpp
)

KDE4_ADD_EXECUTABLE(rekonq-active ${rekonqactive_SRCS})

target_link_libraries(rekonq-active
    ${QT_QTWEBKIT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY} 
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
)

install( TARGETS rekonq-active ${INSTALL_TARGETS_DEFAULT_ARGS} )

# QML-only thing
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.rekonqactive PATTERN .svn EXCLUDE)
install(FILES active-web-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
