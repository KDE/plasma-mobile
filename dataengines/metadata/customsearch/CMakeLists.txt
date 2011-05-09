
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(customsearch_srcs
    ../metadatabaseengine.cpp
    customsearch.cpp
)

nepomuk_add_ontology_classes(
  customsearch_srcs
  ONTOLOGIES
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nexif.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nmo.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
  CLASSES
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nmo#Email"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RasterImage"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Image"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nco#PersonContact"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Website"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Video"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Visual"
  "http://www.semanticdesktop.org/ontologies/2007/05/10/nexif#Photo"

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
)

install(TARGETS plasma_engine_active_customsearch DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-customsearch.desktop DESTINATION ${SERVICES_INSTALL_DIR})

# and more ...
install(FILES plasma-engine-active-persons.desktop DESTINATION ${SERVICES_INSTALL_DIR})

