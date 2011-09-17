project(contour-recommendationengine-documents)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_CURRENT_SOURCE_DIR}
   ${CMAKE_CURRENT_SOURCE_DIR}/../..
   ${CMAKE_CURRENT_BINARY_DIR}
   ${CMAKE_CURRENT_BINARY_DIR}/../..
   ${KDE4_INCLUDES}
   )

set(
    contour_recommendationengine_documents_SRCS
    # RankingsClient.cpp
    Documents.cpp
    ../../RecommendationEngine.cpp
    ../../RecommendationItem.cpp
    )

soprano_add_ontology(
    contour_recommendationengine_documents_SRCS
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
    "NFO" "Nepomuk::Vocabulary" "trig"
    )

soprano_add_ontology(
    contour_recommendationengine_documents_SRCS
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
    "NIE" "Nepomuk::Vocabulary" "trig"
    )

qt4_add_dbus_adaptor(
    contour_recommendationengine_documents_SRCS
    org.kde.ActivityManager.RankingsClient.xml
    Documents_p.h DocumentsEnginePrivate
    )

kde4_add_plugin(
   contour_recommendationengine_documents
   ${contour_recommendationengine_documents_SRCS}
   )

target_link_libraries(
   contour_recommendationengine_documents
   ${QT_QTGUI_LIBRARY}
   ${KDE4_KDECORE_LIBS}
   ${KDE4_KFILE_LIBS}
   ${NEPOMUK_LIBRARIES}
   ${SOPRANO_LIBRARIES}
   kactivities
   )


install(FILES contour-recommendationengine-documents.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(TARGETS contour_recommendationengine_documents DESTINATION ${PLUGIN_INSTALL_DIR})

