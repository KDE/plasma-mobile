
set(mobilecomponentsprivate_SRCS
    mobilecomponentsprivateplugin.cpp
    pagedproxymodel.cpp
    )

add_library(mobilecomponentsprivateplugin SHARED ${mobilecomponentsprivate_SRCS})
target_link_libraries(mobilecomponentsprivateplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS mobilecomponentsprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents/private)


install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobilecomponents/private/)


