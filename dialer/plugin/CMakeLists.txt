set(kpeoplehelper_SRCS
    kpeoplehelper.cpp
    kpeoplehelperplugin.cpp
    )

add_library(kpeoplehelperplugin SHARED ${kpeoplehelper_SRCS})
target_link_libraries(kpeoplehelperplugin Qt5::Core
                                          Qt5::Qml
                                          KF5::People
                                          KF5::PeopleBackend)

install(TARGETS kpeoplehelperplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/kpeoplehelper)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/kpeoplehelper)
