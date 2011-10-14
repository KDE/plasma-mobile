project(datamodels)

include(KDE4Defaults)

set(datamodels_SRCS
    datamodelsplugin.cpp
    metadatamodel.cpp
   )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${datamodels_SRCS})


kde4_add_library(datamodelsplugin SHARED ${datamodels_SRCS})
target_link_libraries(datamodelsplugin 
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDBUS_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${NEPOMUK_LIBRARIES}
        ${NEPOMUK_QUERY_LIBRARIES}
        ${KDE4_KDECORE_LIBRARY}
        ${KDE4_PLASMA_LIBS}
        kactivities)

install(TARGETS datamodelsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/datamodels)


install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/datamodels)
