set(metadatamodeltest_SRCS
    main.cpp
    dynamictreemodel.cpp
    modeltest.cpp
    ../metadatamodel.cpp
    ../abstractmetadatamodel.cpp
    )

soprano_add_ontology(
    metadatamodeltest_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/../ontologies/kext.trig
    "KEXT" "Nepomuk::Vocabulary" "trig"
)

nepomuk_add_ontology_classes (metadatamodeltest_SRCS
                              ONTOLOGIES
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
                              ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nfo.trig
                              CLASSES
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"
                              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#BookmarkFolder"
)

qt4_automoc(${metadatamodeltest_SRCS})
#kde4_add_library(datamodelsplugin SHARED ${datamodels_SRCS})
kde4_add_executable(metadatamodeltest ${metadatamodeltest_SRCS})
target_link_libraries(metadatamodeltest ${QT_QTTEST_LIBRARY} ${KDE4_PLASMA_LIBS} nepomukdatamanagement ${SOPRANO_LIBRARIES}
        ${NEPOMUK_LIBRARIES}
        ${NEPOMUK_QUERY_LIBRARIES})

