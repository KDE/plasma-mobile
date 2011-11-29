project(datamodels)

include(KDE4Defaults)

find_package(Nepomuk REQUIRED)
find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")

include(SopranoAddOntology)
add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)
INCLUDE_DIRECTORIES(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}
    ${KDE4_INCLUDES}
)

set(datamodels_SRCS
    abstractmetadatamodel.cpp
    datamodelsplugin.cpp
    metadatacloudmodel.cpp
    metadatamodel.cpp
    metadatausertypes.cpp
   )

soprano_add_ontology(
    datamodels_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/ontologies/kext.trig
    "KEXT" "Nepomuk::Vocabulary" "trig"
)

nepomuk_add_ontology_classes (datamodels_SRCS
                              ONTOLOGIES
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              CLASSES
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
)

qt4_automoc(${datamodels_SRCS})


kde4_add_library(datamodelsplugin SHARED ${datamodels_SRCS})
target_link_libraries(datamodelsplugin 
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDBUS_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${SOPRANO_LIBRARIES}
        ${NEPOMUK_LIBRARIES}
        ${NEPOMUK_QUERY_LIBRARIES}
        ${KDE4_KDECORE_LIBRARY}
        ${KDE4_PLASMA_LIBS}
        ${KDE4_KIO_LIBS}
        nepomukdatamanagement
        ${KACTIVITIES_LIBRARY}
        )

install(TARGETS datamodelsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/metadatamodels)


install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/metadatamodels)


#add_subdirectory(test)
