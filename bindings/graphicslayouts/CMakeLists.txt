project(graphicslayoutsbindings)

include(KDE4Defaults)

set(graphicslayoutsbindings_SRCS
    graphicslayoutsbindingsplugin.cpp
    gridlayout.cpp
    linearlayout.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${graphicslayoutsbindings_SRCS})


add_library(graphicslayoutsbindingsplugin SHARED ${graphicslayoutsbindings_SRCS})
target_link_libraries(graphicslayoutsbindingsplugin ${QT_QTCORE_LIBRARY} ${QT_QTGUI_LIBRARY} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

install(TARGETS graphicslayoutsbindingsplugin DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicslayouts)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicslayouts)