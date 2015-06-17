include_directories(${TELEPATHY_QT5_INCLUDE_DIR})

set(tpcallerplugin_SRCS
    tp-call-plugin.cpp
    tp-caller.cpp
    )

add_library(tpcallerplugin SHARED ${tpcallerplugin_SRCS})
target_link_libraries(tpcallerplugin Qt5::Core
                                     Qt5::Qml
                                     ${TELEPATHY_QT5_LIBRARIES})

install(TARGETS tpcallerplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/tpcaller)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/tpcaller)
