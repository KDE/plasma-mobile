project(orientationengine)

if (LibKScreen_FOUND AND QTMOBILITY_FOUND AND X11_Xinput_FOUND)

include_directories(${CMAKE_CURRENT_BINARY_DIR}
                    ${QTMOBILITY_INCLUDE_DIR}
                    ${LibKScreen_INCLUDE_DIR}
                    ${QTMOBILITY_SENSORS_INCLUDE_DIR})

set(orientationengine_srcs
    orientationengine.cpp
    orientationservice.cpp
    orientationjob.cpp
)

kde4_add_plugin(plasma_engine_orientation ${orientationengine_srcs})

target_link_libraries(plasma_engine_orientation
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${LibKScreen_LIBRARY}
    ${X11_LIBRARIES}
    ${X11_Xinput_LIB}
    ${QTMOBILITY_SENSORS_LIBRARY}
)

install(TARGETS plasma_engine_orientation DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-orientation.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(FILES orientation.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)

endif()
