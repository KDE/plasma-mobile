project(datamodels)

include(KDE4Defaults)

find_package(NepomukCore REQUIRED)

INCLUDE_DIRECTORIES(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}
    ${KDE4_INCLUDES}
    ${NEPOMUK_CORE_INCLUDE_DIR}
)

set(datamodels_SRCS
    metadatamodel.cpp
    querythread.cpp

    queryproviders/abstractqueryprovider.cpp
    queryproviders/cloudqueryprovider.cpp
    queryproviders/timelinequeryprovider.cpp
    queryproviders/basicqueryprovider.cpp
    queryproviders/resourcequeryprovider.cpp
   )

add_kao_ontology(datamodels_SRCS)



soprano_add_ontology(
    datamodels_SRCS
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/nso.trig
    "NSO" "Nepomuk2::Vocabulary" "trig"
)

nepomuk2_add_ontology_classes (datamodels_SRCS
                              ONTOLOGIES
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              CLASSES
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
)

qt4_automoc(${datamodels_SRCS})


kde4_add_library(nepomukdatamodel SHARED ${datamodels_SRCS})

set_target_properties(nepomukdatamodel PROPERTIES
                      VERSION 1.0
                      SOVERSION 0)

target_link_libraries(nepomukdatamodel
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDBUS_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${SOPRANO_LIBRARIES}
        ${NEPOMUK_CORE_LIBRARY}
        ${NEPOMUK_QUERY_LIBRARIES}
        ${KDE4_KDECORE_LIBRARY}
        ${KDE4_PLASMA_LIBS}
        ${KDE4_KIO_LIBS}
        ${KACTIVITIES_LIBRARY}
        )

install(TARGETS nepomukdatamodel EXPORT kdelibsLibraryTargets ${INSTALL_TARGETS_DEFAULT_ARGS})


install(
   EXPORT kdelibsLibraryTargets
   DESTINATION ${LIB_INSTALL_DIR}/cmake/NepomukDataModel
   FILE NepomukDataModelLibraryTargets.cmake
   )

set(metadataqueryproviders_LIB_HEADERS
    nepomukdatamodel_export.h
    metadatamodel.h

    queryproviders/abstractqueryprovider.h
    queryproviders/basicqueryprovider.h
    queryproviders/timelinequeryprovider.h
    queryproviders/cloudqueryprovider.h
    queryproviders/resourcequeryprovider.h
)

install(FILES ${metadataqueryproviders_LIB_HEADERS} DESTINATION ${INCLUDE_INSTALL_DIR}/ COMPONENT Devel)

configure_file(NepomukDataModelConfig.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/NepomukDataModelConfig.cmake" @ONLY)
configure_file(NepomukDataModelConfigVersion.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/NepomukDataModelConfigVersion.cmake" @ONLY)

install(
   FILES ${CMAKE_CURRENT_BINARY_DIR}/NepomukDataModelConfig.cmake
         ${CMAKE_CURRENT_BINARY_DIR}/NepomukDataModelConfigVersion.cmake
         DESTINATION ${LIB_INSTALL_DIR}/cmake/NepomukDataModel
)


