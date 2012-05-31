
set(active-settings_SRCS
    main.cpp
    activesettings.cpp
    activesettingswindow.cpp
    view.cpp
)

kde4_add_executable(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    ${QT_QTDECLARATIVE_LIBRARY}
    ${KDE4_PLASMA_LIBS}
    ${KDECLARATIVE_LIBRARIES}
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
