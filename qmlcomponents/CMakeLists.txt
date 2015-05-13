project(satellitecomponents)

set(satellitecomponents_SRCS
    satellitecomponentsplugin.cpp
    applicationlistmodel.cpp
    )

add_library(satellitecomponentsplugin SHARED ${satellitecomponents_SRCS})
target_link_libraries(satellitecomponentsplugin
                Qt5::Core
                Qt5::Widgets
                Qt5::Qml
                Qt5::Quick
                KF5::Service
                KF5::Declarative
                KF5::I18n)

install(TARGETS satellitecomponentsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/satellite/components)


install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/satellite/components)

add_subdirectory(modeltest)
