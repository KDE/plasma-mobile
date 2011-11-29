project(plasma-mobile)
cmake_minimum_required (VERSION 2.8)

find_package(KDE4 REQUIRED)
find_package(KActivities REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_BINARY_DIR}/inputmethod
   ${KDE4_INCLUDES}
   )

MACRO(installPackage dir component)
   SET(root ${ARGN})
   IF(NOT root)
        SET(root plasma/plasmoids)
     ENDIF(NOT root)
    install(DIRECTORY ${dir}/ DESTINATION ${DATA_INSTALL_DIR}/${root}/${component} PATTERN Messages.sh EXCLUDE)
    install(FILES ${dir}/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-${component}.desktop)
ENDMACRO(installPackage)

add_subdirectory(applets)
add_subdirectory(applications)
add_subdirectory(artwork)
add_subdirectory(components)
add_subdirectory(containments)
add_subdirectory(dataengines)
add_subdirectory(qmlpackages)
add_subdirectory(virtualkeyboard)
add_subdirectory(wallpapers)
add_subdirectory(shell)
add_subdirectory(widgetstrip-shell)

if (BUILD_HANDSET)
   add_subdirectory(handset)
endif (BUILD_HANDSET)
