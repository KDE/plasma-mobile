find_package(KDE4 REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   )

add_subdirectory(applets)
add_subdirectory(containments)
add_subdirectory(desktoptheme)
add_subdirectory(bindings)
add_subdirectory(examples)
if(NOT WIN32)
add_subdirectory(shell)
endif(NOT WIN32)
