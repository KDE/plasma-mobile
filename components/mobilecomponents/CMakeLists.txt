project(mobilecomponents)

include(KDE4Defaults)

set(mobilecomponents_SRCS
    appletcontainer.cpp
    mobilecomponentsplugin.cpp
    pagedproxymodel.cpp
    fallbackcomponent.cpp
    package.cpp
    texteffects.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${mobilecomponents_SRCS})


kde4_add_library(mobilecomponentsplugin SHARED ${mobilecomponents_SRCS})
target_link_libraries(mobilecomponentsplugin ${QT_QTCORE_LIBRARY} ${QT_QTDBUS_LIBRARY}  ${QT_QTGUI_LIBRARY} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDECORE_LIBRARY} ${KDE4_PLASMA_LIBS} ${KACTIVITIES_LIBRARY})

install(TARGETS mobilecomponentsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES ActionButton.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES Rating.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconButton.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconGrid.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES ResourceDelegate.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES Sheet.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES ViewSearch.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(DIRECTORY animations/ DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
#install(FILES DisappearAnimation.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(DIRECTORY resourcedelegates/ DESTINATION ${DATA_INSTALL_DIR}/plasma/resourcedelegates/)
