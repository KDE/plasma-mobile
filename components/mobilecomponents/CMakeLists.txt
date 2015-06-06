project(mobilecomponents)

set(mobilecomponents_SRCS
    mobilecomponentsplugin.cpp
    pagedproxymodel.cpp
    fallbackcomponent.cpp
    package.cpp
    applicationlistmodel.cpp
    #texteffects.cpp
    )

add_library(mobilecomponentsplugin SHARED ${mobilecomponents_SRCS})
target_link_libraries(mobilecomponentsplugin Qt5::Core Qt5::Widgets Qt5::Qml Qt5::Quick KF5::Declarative KF5::Plasma KF5::I18n KF5::KIOCore KF5::KIOWidgets KF5::Activities)

install(TARGETS mobilecomponentsplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES Rating.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconButton.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES IconGrid.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES ResourceDelegate.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES ViewSearch.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES OverlayDrawer.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
install(FILES SplitDrawer.qml DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(FILES qmldir DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)

install(DIRECTORY resourcedelegates DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mobilecomponents)
