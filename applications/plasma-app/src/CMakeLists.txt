
# These are only needed here, consider porting away from both!
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Gui)

set(plasma-app_SRCS
    main.cpp
    view.cpp
)

add_executable(plasma-app ${plasma-app_SRCS})

target_link_libraries(plasma-app
    Qt5::Quick
    Qt5::Gui
    KF5::Plasma
    KF5::Declarative
    KF5::I18n
)

install( TARGETS plasma-app ${INSTALL_TARGETS_DEFAULT_ARGS} )
