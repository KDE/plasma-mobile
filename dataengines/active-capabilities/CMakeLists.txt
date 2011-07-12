project(capabilitiesengine)

include_directories(
                    ${CMAKE_CURRENT_BINARY_DIR}
   )

set(capability_srcs
    capabilitiesengine.cpp
)

kde4_add_plugin(plasma_engine_active_capabilities ${capability_srcs})

target_link_libraries(plasma_engine_active_capabilities
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
    #${KDE4_KIO_LIBS}
)

install(TARGETS plasma_engine_active_capabilities DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-active-capabilities.desktop DESTINATION ${SERVICES_INSTALL_DIR})

