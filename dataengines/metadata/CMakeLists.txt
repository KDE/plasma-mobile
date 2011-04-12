project(metadataengine)


find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")



include(SopranoAddOntology)

include_directories(
                    ${CMAKE_CURRENT_BINARY_DIR}
   )

set(metadataengine_srcs
    metadataengine.cpp
)

kde4_add_plugin(plasma_engine_metadata ${metadataengine_srcs})

target_link_libraries(plasma_engine_metadata
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${NEPOMUK_LIBRARIES}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${SOPRANO_LIBRARIES}
    ${SOPRANO_CLIENT_LIBRARIES}
)

install(TARGETS plasma_engine_metadata DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR})

