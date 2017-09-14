cmake_minimum_required(VERSION 2.8.12)

project(touchtest LANGUAGES CXX)


SET(touchtest_SRC
    main.cpp
)

QT5_ADD_RESOURCES(touchtest_SRC
    qml.qrc
)

add_executable(touchtest ${touchtest_SRC})

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Widgets)

INSTALL( TARGETS touchtest DESTINATION bin)
INSTALL( PROGRAMS org.kde.touchtest.desktop  DESTINATION ${KDE_INSTALL_APPDIR} )
