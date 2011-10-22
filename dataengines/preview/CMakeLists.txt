project(previewengine)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(previewengine_srcs
    previewengine.cpp
    previewcontainer.cpp
)

kde4_add_plugin(plasma_engine_preview ${previewengine_srcs})

target_link_libraries(plasma_engine_preview
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
)

install(TARGETS plasma_engine_preview DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-preview.desktop DESTINATION ${SERVICES_INSTALL_DIR})

