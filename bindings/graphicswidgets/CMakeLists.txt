project(graphicswidgetsbindings)

include(KDE4Defaults)

set(graphicswidgetsbindings_SRCS
    graphicswidgetsbindingsplugin.cpp
    declarativetabbar.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${graphicswidgetsbindings_SRCS})


add_library(graphicswidgetsbindingsplugin SHARED ${graphicswidgetsbindings_SRCS})
target_link_libraries(graphicswidgetsbindingsplugin ${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

install(TARGETS graphicswidgetsbindingsplugin DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicswidgets)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicswidgets)