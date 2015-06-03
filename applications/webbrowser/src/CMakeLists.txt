
# These are only needed here, consider porting away from both!
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Gui WebEngine)

set(angelfish_SRCS
    main.cpp
    browsermanager.cpp
    urlmodel.cpp
    view.cpp
)

add_executable(angelfish ${angelfish_SRCS})

target_link_libraries(angelfish
    Qt5::Quick
    Qt5::Gui
    Qt5::WebEngine
    KF5::Plasma
    KF5::Declarative
    KF5::I18n
)

install( TARGETS angelfish ${INSTALL_TARGETS_DEFAULT_ARGS} )
