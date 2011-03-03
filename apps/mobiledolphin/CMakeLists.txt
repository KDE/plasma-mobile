set(KDE_MIN_VERSION 4.6.0)
find_package(KDE4 REQUIRED)

include (KDE4Defaults)
include_directories( ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES})

set(mobiledolphin_SRCS main.cpp mobiledolphin.cpp kdeclarativedirmodel.cpp)

kde4_add_executable(mobiledolphin ${mobiledolphin_SRCS})

target_link_libraries(mobiledolphin kdeclarative ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDEUI_LIBS} ${KDE4_KIO_LIBS})

install(TARGETS mobiledolphin ${INSTALL_TARGETS_DEFAULT_ARGS} )
