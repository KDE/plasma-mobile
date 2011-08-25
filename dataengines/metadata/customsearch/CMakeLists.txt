
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(customsearch_srcs
    ../metadatabaseengine.cpp
    ../querycontainer.cpp
    ../metadataservice/metadatajob.cpp
    ../metadataservice/metadataservice.cpp
    customsearch.cpp
)

kde4_add_plugin(plasma_engine_active_customsearch ${customsearch_srcs})

target_link_libraries(plasma_engine_active_customsearch
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

install(TARGETS plasma_engine_active_customsearch DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-customsearch.desktop DESTINATION ${SERVICES_INSTALL_DIR})

# and more ...
install(FILES plasma-engine-active-persons.desktop DESTINATION ${SERVICES_INSTALL_DIR})

