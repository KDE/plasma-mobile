project(capabilitiesengine)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(capability_srcs
    capabilitiesengine.cpp
    powermanagementjob.cpp
    powermanagementservice.cpp
)

kde4_add_plugin(plasma_engine_devicecapabilities ${capability_srcs})

target_link_libraries(plasma_engine_devicecapabilities
    ${KDE4_KDECORE_LIBS}
    ${KDE4_PLASMA_LIBS}
)

# Engine
install(TARGETS plasma_engine_devicecapabilities DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-devicecapabilities.desktop DESTINATION ${SERVICES_INSTALL_DIR})

# Services
#install(FILES powermanagementservice.operations
#        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)

