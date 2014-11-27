
set(active-settings_SRCS
    main.cpp
    activesettings.cpp
    activesettingswindow.cpp
    view.cpp
)

add_executable(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    Qt5::Quick
    KF5::Plasma
    KF5::KDeclarative
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
