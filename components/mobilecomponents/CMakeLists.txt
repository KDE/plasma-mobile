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

install(DIRECTORY  ${PROJECT_SOURCE_DIR} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/)


