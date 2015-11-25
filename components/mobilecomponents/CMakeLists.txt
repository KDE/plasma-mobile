project(mobilecomponents)

set(mobilecomponents_SRCS
    mobilecomponentsplugin.cpp
    )

add_library(mobilecomponentsplugin SHARED ${mobilecomponents_SRCS})
target_link_libraries(mobilecomponentsplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS mobilecomponentsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)


install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)


#TODO: install the plasmaless version at build time
#TODO: use the same way qquickcontrols2 uses to select if possible
FILE(GLOB platformspecific ${PROJECT_SOURCE_DIR}/plasmatheme/*)


install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents)

add_subdirectory(private)

