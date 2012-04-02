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


set_target_properties(activeapp PROPERTIES VERSION ${KDE_NON_GENERIC_LIB_VERSION} SOVERSION ${KDE_NON_GENERIC_LIB_SOVERSION})

install(FILES ${activeApp_HEADERS} DESTINATION ${INCLUDE_INSTALL_DIR}/ COMPONENT Devel)

install(TARGETS activeapp EXPORT activeappLibraryTargets ${INSTALL_TARGETS_DEFAULT_ARGS})
