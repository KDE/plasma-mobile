project(mobilecomponents)

include(KDE4Defaults)

set(mobilecomponents_SRCS
    mobilecomponentsplugin.cpp
    pagedproxymodel.cpp
    appletstatuswatcher.cpp
    resourcedelegate.cpp
    categorizedproxymodel.cpp
    mouseeventlistener.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${mobilecomponents_SRCS})


add_library(mobilecomponentsplugin SHARED ${mobilecomponents_SRCS})
target_link_libraries(mobilecomponentsplugin ${QT_QTCORE_LIBRARY} ${QT_QTDBUS_LIBRARY}  ${QT_QTGUI_LIBRARY} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDECORE_LIBRARY} ${KDE4_PLASMA_LIBS})

install(TARGETS mobilecomponentsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES ActionsModel.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES ContextMenu.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES MenuItem.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES Rating.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES RatingIcon.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconGrid.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconDelegate.qml DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(DIRECTORY resourcedelegates/ DESTINATION ${DATA_INSTALL_DIR}/plasma/resourcedelegates/)
install(DIRECTORY menuitems/ DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/plasma/mobilecomponents/menuitems/)
