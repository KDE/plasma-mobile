include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES})

set(mobilenetwork_engine_SRCS
    mobilenetworkengine.cpp
    mobilenetworksource.cpp
)

kde4_add_plugin(plasma_engine_mobilenetwork ${mobilenetwork_engine_SRCS})
target_link_libraries(plasma_engine_mobilenetwork ofono-qt ${KDE4_PLASMA_LIBS})

install(TARGETS plasma_engine_mobilenetwork DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-mobilenetwork.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

