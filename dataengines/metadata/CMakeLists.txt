project(metadataengine)


find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")



include(SopranoAddOntology)

include_directories(
                    ${CMAKE_CURRENT_BINARY_DIR}
   )

add_subdirectory(metadata)
add_subdirectory(bookmarks)
