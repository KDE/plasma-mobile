
set(active-settings_SRCS
    main.cpp
    activesettings.cpp
    activesettingswindow.cpp
    view.cpp
    settingsmodulesitem.cpp
    settingsmodulesmodel.cpp
    settingsmodule.cpp
    settingsmoduleloader.cpp
    configmodel.cpp
)

KDE4_ADD_EXECUTABLE(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    ${QT_QTDECLARATIVE_LIBRARY}
    #${KDE4_KDEUI_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
     #${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY}
    #kactivities
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
