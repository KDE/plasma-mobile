project(metadataengine)

# disable deprecated libnepomuk stuff for less compiler warnings
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)

find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")

include(SopranoAddOntology)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/ontologies
    #${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(metadataengine_SRCS
    metadataengine.cpp
    querycontainer.cpp
    metadataservice/metadatajob.cpp
    metadataservice/metadataservice.cpp
)

soprano_add_ontology(
        metadataengine_SRCS
        ${CMAKE_CURRENT_SOURCE_DIR}/ontologies/kext.trig
        "KEXT" "Nepomuk::Vocabulary" "trig"
    )

# nepomuk_add_ontology_classes (metadataengine_SRCS
#                               ONTOLOGIES
#                               ${CMAKE_SOURCE_DIR}/ontologies/kext.trig
#                               CLASSES
#                               "KEXT"
# )

kde4_add_plugin(plasma_engine_active_metadata ${metadataengine_SRCS})

target_link_libraries(plasma_engine_active_metadata
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${NEPOMUK_LIBRARIES}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${SOPRANO_LIBRARIES}
    ${SOPRANO_CLIENT_LIBRARIES}
    kactivities
    ontologies
    nepomukdatamanagement
)

install(TARGETS plasma_engine_active_metadata DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR})



install(FILES metadataservice/metadataservice.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)
