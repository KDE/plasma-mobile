project(mobilecomponents)

set(mobilecomponents_SRCS
    mobilecomponentsplugin.cpp
    pagedproxymodel.cpp
    package.cpp
    applicationlistmodel.cpp
    fullscreenpanel.cpp
    )

add_library(mobilecomponentsplugin SHARED ${mobilecomponents_SRCS})
target_link_libraries(mobilecomponentsplugin Qt5::Core Qt5::Widgets Qt5::Qml Qt5::Quick KF5::Declarative KF5::Plasma KF5::I18n KF5::KIOCore KF5::KIOWidgets KF5::Activities KF5::WindowSystem KF5::WaylandClient)

install(TARGETS mobilecomponentsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)


FILE(GLOB qml ${PROJECT_SOURCE_DIR}/qml/*)

install(FILES ${qml} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)


FILE(GLOB platformspecific ${PROJECT_SOURCE_DIR}/plasmatheme/*)

install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)
