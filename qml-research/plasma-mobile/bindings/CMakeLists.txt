project(bindings)

set(bindings_SRCS
    plasmabindings.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

add_library(plasma_bindings SHARED ${bindings_SRCS})
target_link_libraries(plasma_bindings ${KDE4_PLASMA_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY})

install(TARGETS plasma_bindings DESTINATION ${INSTALL_TARGETS_DEFAULT_ARGS})
