include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES}
${QT_QTNETWORK_INCLUDES} ${QT_QTXML_INCLUDES} ${QCA2_INCLUDE_DIR} ${CMAKE_SOURCE_DIR}/contourd/recommendation)

set(recommendations_engine_SRCS
    recommendationsengine.cpp
    recommendationservice.cpp
    recommendationjob.cpp
)

kde4_add_plugin(plasma_engine_recommendations ${recommendations_engine_SRCS})
target_link_libraries(plasma_engine_recommendations ${KDE4_PLASMA_LIBS}  ${NEPOMUK_LIBRARIES} contourclient)

install(TARGETS plasma_engine_recommendations DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-recommendations.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

