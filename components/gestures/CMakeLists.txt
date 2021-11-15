
set(gesturesplugin_SRCS
    gesturesplugin.cpp
    direction.cpp
)

add_library(gesturesplugin ${gesturesplugin_SRCS})

target_link_libraries(gesturesplugin
        PUBLIC
            Qt::Core
        PRIVATE
            Qt::Qml
            Qt::Quick
    )
    
# DANGER! DANGER! Using Qt's private API!
include_directories(
    SYSTEM
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
)

install(TARGETS gesturesplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/gestures)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/gestures)

