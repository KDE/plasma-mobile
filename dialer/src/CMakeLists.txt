

set(plasmaphonedialer_SRCS
    main.cpp
)

add_executable(plasmaphonedialer ${plasmaphonedialer_SRCS})
target_compile_definitions(plasmaphonedialer PRIVATE -DPROJECT_VERSION="${PROJECT_VERSION}")

#find_package(ActiveApp REQUIRED)

target_link_libraries(plasmaphonedialer
 Qt5::Gui
 Qt5::Quick
 Qt5::Widgets
 KF5::Declarative
 KF5::I18n
 KF5::Package
 KF5::QuickAddons
 KF5::DBusAddons
)

install(TARGETS plasmaphonedialer ${INSTALL_TARGETS_DEFAULT_ARGS})
