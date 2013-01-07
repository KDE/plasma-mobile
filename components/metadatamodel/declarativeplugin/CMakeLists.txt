project(datamodels)

include(KDE4Defaults)

find_package(NepomukCore REQUIRED)

INCLUDE_DIRECTORIES(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}
    ${KDE4_INCLUDES}
    ${NEPOMUK_CORE_INCLUDE_DIR}
    ../library
)

set(datamodels_SRCS
    datamodelsplugin.cpp
    metadatausertypes.cpp
   )


qt4_automoc(${datamodels_SRCS})

add_kao_ontology(datamodels_SRCS)



soprano_add_ontology(
    datamodels_SRCS
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/nso.trig
    "NSO" "Nepomuk2::Vocabulary" "trig"
)


kde4_add_library(datamodelsplugin SHARED ${datamodels_SRCS})
target_link_libraries(datamodelsplugin
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${KDE4_KDECORE_LIBRARY}
        nepomukdatamodel
        )

install(TARGETS datamodelsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/metadatamodels)


install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/metadatamodels)


