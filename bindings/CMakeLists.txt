project(bindings)

include(KDE4Defaults)

set(bindings_SRCS
    plasmabindings.cpp
    phone/phone.cpp
    private/declarative/declarativetabbar.cpp
    private/declarative/gridlayout.cpp
    private/declarative/linearlayout.cpp
    private/declarative/dataengineconsumer.cpp
    private/declarative/theme.cpp
    private/declarative/datasource.cpp
    private/declarative/svgitem.cpp
    private/declarative/framesvgitem.cpp
    )

set(graphicswidgetsbindings_SRCS
    graphicswidgetsbindingsplugin.cpp
    phone/phone.cpp
    private/declarative/declarativetabbar.cpp
    private/declarative/gridlayout.cpp
    private/declarative/linearlayout.cpp
    private/declarative/dataengineconsumer.cpp
    private/declarative/theme.cpp
    private/declarative/datasource.cpp
    private/declarative/svgitem.cpp
    private/declarative/framesvgitem.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${bindings_SRCS})
qt4_automoc(${graphicswidgetsbindings_SRCS})

add_library(plasma_bindings SHARED ${bindings_SRCS})
target_link_libraries(plasma_bindings ${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

add_library(graphicswidgetsbindingsplugin SHARED ${graphicswidgetsbindings_SRCS})
target_link_libraries(graphicswidgetsbindingsplugin ${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

install(TARGETS plasma_bindings DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS})

install(TARGETS graphicswidgetsbindingsplugin DESTINATION ${QT_INCLUDE_DIR}/../imports/org/kde/plasma/graphicswidgets)
#install(TARGETS graphicswidgetsbindingsplugin DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicswidgets)
install(FILES qmldir DESTINATION ${QT_INCLUDE_DIR}/../imports/org/kde/plasma/graphicswidgets)
#install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/graphicswidgets)