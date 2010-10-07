project(bindings)

include(KDE4Defaults)

add_subdirectory(graphicslayouts)
add_subdirectory(graphicswidgets)

set(bindings_SRCS
    plasmabindings.cpp
    phone/phone.cpp
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

add_library(plasma_bindings SHARED ${bindings_SRCS})
target_link_libraries(plasma_bindings ${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

install(TARGETS plasma_bindings DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS})
