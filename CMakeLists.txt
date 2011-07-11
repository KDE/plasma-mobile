find_package(KDE4 REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_BINARY_DIR}/inputmethod
   ${KDE4_INCLUDES}
   )

add_subdirectory(applets)
add_subdirectory(components)
add_subdirectory(containments)
add_subdirectory(dataengines)
add_subdirectory(desktoptheme)
add_subdirectory(mousetheme)
add_subdirectory(mobilebusynotifier)
add_subdirectory(virtualkeyboard)
add_subdirectory(wallpapers)
add_subdirectory(shell)
