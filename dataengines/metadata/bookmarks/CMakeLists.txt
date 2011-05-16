
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(bookmarksdataengine_srcs
    ../metadatabaseengine.cpp
    ../querycontainer.cpp
    ../activityservice/activityjob.cpp
    ../activityservice/activityservice.cpp
    ../metadataservice/metadatajob.cpp
    ../metadataservice/metadataservice.cpp
    bookmarksengine.cpp
)


nepomuk_add_ontology_classes(
  bookmarksdataengine_srcs
  ONTOLOGIES
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nexif.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nmo.trig
  ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
  CLASSES
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nmo#Email"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RasterImage"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Image"
  #nmo:Email
  #nfo:Image
  #nfo:RasterImage
  #nco:PersonContact
  #nfo:Website
  #nfo:Video
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nco#PersonContact"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Website"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmarks"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Video"
  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Visual"
  "http://www.semanticdesktop.org/ontologies/2007/05/10/nexif#Photo"

  )


kde4_add_plugin(plasma_engine_active_bookmarks ${bookmarksdataengine_srcs})

target_link_libraries(plasma_engine_active_bookmarks
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${NEPOMUK_LIBRARIES}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${SOPRANO_LIBRARIES}
    ${SOPRANO_CLIENT_LIBRARIES}
    kactivities
)

install(TARGETS plasma_engine_active_bookmarks DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-bookmarks.desktop DESTINATION ${SERVICES_INSTALL_DIR})

