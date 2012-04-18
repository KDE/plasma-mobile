project(activeApp)

find_package(KDE4 REQUIRED)
include(KDE4Defaults)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_KIO_INCLUDES}
   ${CMAKE_SOURCE_DIR}/kio
   )

set (activeApp_HEADERS
     activeapp_export.h
     kdeclarativemainwindow.h
     #maybe not to be installed
     #kdeclarativeview.h
    )

set (activeApp_SRCS
     dataenginebindings.cpp
     kdeclarativemainwindow.cpp
     kdeclarativeview.cpp
     )



qt4_automoc(${activeApp_SRCS})

kde4_add_library (activeapp SHARED ${activeApp_SRCS})
target_link_libraries(activeapp  ${KDE4_KDECORE_LIBS} ${QT_QTOPENGL_LIBRARY} ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS} ${QT_QTDECLARATIVE_LIBRARY} ${QT_QTSCRIPT_LIBRARY} kdeclarative)


set_target_properties(activeapp PROPERTIES VERSION 0.1 SOVERSION 0)

install(FILES ${activeApp_HEADERS} DESTINATION ${INCLUDE_INSTALL_DIR}/ COMPONENT Devel)

INSTALL(
    FILES FindActiveApp.cmake
    DESTINATION ${LIB_INSTALL_DIR}/cmake/ActiveApp
)

install(TARGETS activeapp EXPORT activeappLibraryTargets ${INSTALL_TARGETS_DEFAULT_ARGS})
