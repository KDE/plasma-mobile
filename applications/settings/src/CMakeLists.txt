
find_package(KF5 REQUIRED COMPONENTS KDELibs4Support)

set(active-settings_SRCS
    main.cpp
    activesettings.cpp
    activesettingswindow.cpp
    view.cpp
)

add_executable(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    Qt5::Quick
    Qt5::Gui
    KF5::Plasma
    KF5::KDeclarative
    KF5::KDELibs4Support
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
