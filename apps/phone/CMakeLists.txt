set(KDE_MIN_VERSION 4.6.0)
find_package(KDE4 REQUIRED)

include (KDE4Defaults)
include_directories( ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES})

set(mobiledolphin_SRCS main.cpp phonemanager.cpp)

kde4_add_executable(plasmaphone ${mobiledolphin_SRCS})

target_link_libraries(plasmaphone ofono-qt kdeclarative ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDEUI_LIBS} ${KDE4_KIO_LIBS})

install(TARGETS plasmaphone ${INSTALL_TARGETS_DEFAULT_ARGS} )
