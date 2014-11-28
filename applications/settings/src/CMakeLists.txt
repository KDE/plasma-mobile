
# These are only needed here, consider porting away from both!
find_package(KF5 REQUIRED COMPONENTS KDELibs4Support)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Gui)

set(active-settings_SRCS
    main.cpp
#     activesettings.cpp
#    activesettingswindow.cpp
    view.cpp
)

add_executable(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    Qt5::Quick
    Qt5::Gui
    KF5::Plasma
    KF5::Declarative
    KF5::I18n
    #KF5::KDELibs4Support
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
