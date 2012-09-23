project(plasma-mobile)
cmake_minimum_required (VERSION 2.8)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

find_package(KDE4 REQUIRED)
find_package(KActivities 6.0.0 REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)

find_package(Nepomuk REQUIRED)
find_package(Soprano)

macro_log_feature(
   Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
   TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk"
   )

find_package(KDeclarative REQUIRED)

macro_log_feature(
    KDeclarative_FOUND "libkdeclarative" "KDE Declarative (QML) support from kdelibs" "http://www.kde.org"
    TRUE "" ""
    )

include(SopranoAddOntology)
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_BINARY_DIR}/inputmethod
   ${KDE4_INCLUDES}
   ${KDECLARATIVE_INCLUDE_DIR}
   )

MACRO(installPackage dir component)
   SET(root ${ARGN})
   IF(NOT root)
        SET(root plasma/plasmoids)
     ENDIF(NOT root)
    install(DIRECTORY ${dir}/ DESTINATION ${DATA_INSTALL_DIR}/${root}/${component} PATTERN Messages.sh EXCLUDE)
    install(FILES ${dir}/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-${component}.desktop)
ENDMACRO(installPackage)

MACRO(add_kao_ontology var)
   soprano_add_ontology(
      ${var}
      ${KACTIVITIES_ONTOLOGIES_DIR}/kao.trig
      "KAO" "Nepomuk::Vocabulary" "trig"
   )
ENDMACRO(add_kao_ontology)

add_subdirectory(applets)
add_subdirectory(applications)
add_subdirectory(artwork)
add_subdirectory(components)
add_subdirectory(containments)
add_subdirectory(dataengines)
add_subdirectory(qmlpackages)
add_subdirectory(runners)
add_subdirectory(shell)
add_subdirectory(wallpapers)
add_subdirectory(widgetstrip-shell)

if (BUILD_HANDSET)
   add_subdirectory(handset)
endif (BUILD_HANDSET)
