find_package(KDE4 REQUIRED)

include(KDE4Defaults)

MACRO(install_metadata_file metadata dest)
   configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${metadata} ${CMAKE_CURRENT_BINARY_DIR}/${dest} COPYONLY)
   install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${dest} DESTINATION ${SERVICES_INSTALL_DIR})
ENDMACRO(install_metadata_file)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_BINARY_DIR}/inputmethod
   ${KDE4_INCLUDES}
   )

add_subdirectory(applets)
add_subdirectory(config)
add_subdirectory(containments)
add_subdirectory(dataengines)
add_subdirectory(desktoptheme)
add_subdirectory(mousetheme)
add_subdirectory(mobilebusynotifier)
add_subdirectory(bindings)
add_subdirectory(virtualkeyboard)
add_subdirectory(wallpapers)
if(NOT WIN32)
add_subdirectory(shell)
endif(NOT WIN32)
