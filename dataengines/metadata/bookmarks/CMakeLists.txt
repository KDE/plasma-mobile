
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
   )

set(bookmarksdataengine_srcs
    ../metadatabaseengine.cpp
    ../querycontainer.cpp
    ../metadataservice/metadatajob.cpp
    ../metadataservice/metadataservice.cpp
    bookmarksengine.cpp
    ${CMAKE_SOURCE_DIR}/nepomuklegacy/resourcewatcher.cpp
)

add_kao_ontology(bookmarksdataengine_srcs)

qt4_add_dbus_interface(datamodels_SRCS
  ${CMAKE_SOURCE_DIR}/nepomuklegacy/org.kde.nepomuk.ResourceWatcherConnection.xml
  resourcewatcherconnectioninterface)

qt4_add_dbus_interface(datamodels_SRCS
   ${CMAKE_SOURCE_DIR}/nepomuklegacy/org.kde.nepomuk.ResourceWatcher.xml
  resourcewatchermanagerinterface)


kde4_add_plugin(plasma_engine_active_bookmarks ${bookmarksdataengine_srcs})

target_link_libraries(plasma_engine_active_bookmarks
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${NEPOMUK_LIBRARIES}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${SOPRANO_LIBRARIES}
    ${SOPRANO_CLIENT_LIBRARIES}
    ${KACTIVITIES_LIBRARY}
    ontologies
)

install(TARGETS plasma_engine_active_bookmarks DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-bookmarks.desktop DESTINATION ${SERVICES_INSTALL_DIR})

