project(metadataengine)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/ontologies
)

find_package(NepomukCore REQUIRED)

set(metadataengine_SRCS
    metadataengine.cpp
    resourcecontainer.cpp
    metadataservice/metadatajob.cpp
    metadataservice/metadataservice.cpp
)

add_kao_ontology(metadataengine_SRCS)

nepomuk_add_ontology_classes (metadataengine_SRCS
    ONTOLOGIES
    NEPOMUK2
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
    CLASSES
    "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
    "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
)

kde4_add_plugin(plasma_engine_active_metadata ${metadataengine_SRCS})

target_link_libraries(plasma_engine_active_metadata
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${NEPOMUK_CORE_LIBRARY}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${SOPRANO_LIBRARIES}
    ${SOPRANO_CLIENT_LIBRARIES}
    ${KACTIVITIES_LIBRARY}
    ontologies
)

install(TARGETS plasma_engine_active_metadata DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(FILES metadataservice/metadataservice.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)
