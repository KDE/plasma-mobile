project(bindings)

include(KDE4Defaults)

set(bindings_SRCS
    plasmabindings.cpp
    private/declarativetabbar.cpp
    private/graphicslayouts.cpp
    #datasource.cpp
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
