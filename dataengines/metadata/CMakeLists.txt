project(metadataengine)

# disable deprecated libnepomuk stuff for less compiler warnings
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)

find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")



include(SopranoAddOntology)

include_directories(
    ${CMAKE_BINARY_DIR}/ontologies
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

add_subdirectory(ontologies)
add_subdirectory(metadata)
add_subdirectory(bookmarks)
add_subdirectory(customsearch)


install(FILES activityservice/activityresources.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)