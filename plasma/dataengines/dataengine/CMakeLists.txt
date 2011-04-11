include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES}
${QT_QTNETWORK_INCLUDES} ${QT_QTXML_INCLUDES} ${QCA2_INCLUDE_DIR})

set(nepomukmobile_engine_SRCS
    nepomukmobileengine.cpp
    testsource.cpp
    recommendation.cpp
    recommendationaction.cpp
    recommendationtype.cpp
)

set(contour_xml org.kde.contour.RecommendationManager.xml)

set_source_files_properties(${contour_xml} PROPERTIES
   NO_NAMESPACE false
   INCLUDE "recommendationtype.h"
   CLASSNAME OrgKdeContourRecommendationManagerInterface
)

QT4_ADD_DBUS_INTERFACE(nepomukmobile_engine_SRCS ${contour_xml} contour_interface)

kde4_add_plugin(plasma_engine_nepomukmobile ${nepomukmobile_engine_SRCS})
target_link_libraries(plasma_engine_nepomukmobile ${KDE4_KIO_LIBS}
${KDE4_PLASMA_LIBS} ${QT_QTXML_LIBS} ${QT_QTNETWORK_LIBS} ${QCA2_LIBRARIES})

install(TARGETS plasma_engine_nepomukmobile DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-nepomukmobile.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

