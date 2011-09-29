
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(metadataengine_srcs
    ../metadatabaseengine.cpp
    ../querycontainer.cpp
    ../metadataservice/metadatajob.cpp
    ../metadataservice/metadataservice.cpp
    metadataengine.cpp
)

soprano_add_ontology(
        metadataengine_srcs
        ${CMAKE_CURRENT_SOURCE_DIR}/../ontologies/kext.trig
        "KEXT" "Nepomuk::Vocabulary" "trig"
    )

# nepomuk_add_ontology_classes (metadataengine_srcs
#                               ONTOLOGIES
#                               ${CMAKE_SOURCE_DIR}/ontologies/kext.trig
#                               CLASSES
#                               "KEXT"
# )

kde4_add_plugin(plasma_engine_active_metadata ${metadataengine_srcs})

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

