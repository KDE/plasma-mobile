project(mobileshellprivate)

set(mobileshellprivate_SRCS
    mobileshellprivateplugin.cpp
    fullscreenpanel.cpp
    )

add_library(plasmamobileshellprivateplugin SHARED ${mobileshellprivate_SRCS})
target_link_libraries(plasmamobileshellprivateplugin Qt5::Core Qt5::Qml Qt5::Quick  KF5::WindowSystem KF5::WaylandClient)

install(TARGETS plasmamobileshellprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)


