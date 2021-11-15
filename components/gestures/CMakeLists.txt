
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
    
install(TARGETS gesturesplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/gestures)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/gestures)

