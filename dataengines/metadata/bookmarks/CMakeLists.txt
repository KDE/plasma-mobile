
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

find_file(kext_onto_src kext.trig PATH_SUFFIXES "ontology/kde" PATHS ${CMAKE_INSTALL_PREFIX}/share ENV XDG_DATA_DIRS)
soprano_add_ontology(bookmarksdataengine_srcs ${kext_onto_src} "KExt" "Nepomuk::Vocabulary" "trig")

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
    ontologies
)

install(TARGETS plasma_engine_active_bookmarks DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-bookmarks.desktop DESTINATION ${SERVICES_INSTALL_DIR})

