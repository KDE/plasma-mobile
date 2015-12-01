project(mobileshellprivate)

set(mobileshellprivate_SRCS
    mobileshellprivateplugin.cpp
    fullscreenpanel.cpp
    )

add_library(mobileshellprivateplugin SHARED ${mobileshellprivate_SRCS})
target_link_libraries(mobileshellprivateplugin Qt5::Core Qt5::Widgets Qt5::Qml Qt5::Quick KF5::Declarative KF5::Plasma KF5::I18n KF5::KIOCore KF5::KIOWidgets KF5::Activities KF5::WindowSystem KF5::WaylandClient)

install(TARGETS mobileshellprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)




