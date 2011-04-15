project(contourd)



# build stuff
# ===============================================================================================
include_directories(
  ${contour_SOURCE_DIR}/contourd/location
  ${contour_SOURCE_DIR}/contourd/recommendation
  ${contour_BINARY_DIR}
  ${QT_INCLUDES}
  ${KDE4_INCLUDES}
  ${NEPOMUK_INCLUDE_DIR}
  ${SOPRANO_INCLUDE_DIR}
#hack to find qt-mobility includes. TODO: get cmake macro
  ${INCLUDE_INSTALL_DIR}/QtMobility
  ${INCLUDE_INSTALL_DIR}/QtMobility/QtMobility
)

set(recommendationmanager_SRC
  recommendation/recommendationaction.cpp
  recommendation/recommendation.cpp
  recommendation/recommendationmanager.cpp
  recommendation/dbusoperators.cpp
  location/locationmanager.cpp
  main.cpp
)

set(recommendationmanager_xml recommendation/org.kde.contour.RecommendationManager.xml)

qt4_add_dbus_adaptor(
  recommendationmanager_SRC
  ${recommendationmanager_xml}
  "recommendationmanager.h"
  "Contour::RecommendationManager"
  "recommendationmanageradaptor")

find_file(kext_onto_src kext.trig PATH_SUFFIXES "ontology/kde" PATHS ${CMAKE_INSTALL_PREFIX}/share ENV XDG_DATA_DIRS)
soprano_add_ontology(recommendationmanager_SRC ${kext_onto_src} "KExt" "Nepomuk::Vocabulary" "trig")

kde4_add_executable(contour
  ${recommendationmanager_SRC}
)

target_link_libraries(
  contour
  ${QT_QTCORE_LIBRARY}
  ${KDE4_KDECORE_LIBS}
  ${SOPRANO_LIBRARIES}
  ${NEPOMUK_LIBRARIES}
  ${NEPOMUK_QUERY_LIBRARIES}
  kworkspace
  QtLocation
)

set(recommendationsclient_SRC
  recommendation/recommendationaction.cpp
  recommendation/recommendation.cpp
  recommendation/dbusoperators.cpp
  recommendation/recommendationsclient.cpp
)

set_source_files_properties(${recommendationmanager_xml} PROPERTIES
   NO_NAMESPACE false
   INCLUDE "dbusoperators.h"
   CLASSNAME OrgKdeContourRecommendationManagerInterface
)

QT4_ADD_DBUS_INTERFACE(recommendationsclient_SRC ${recommendationmanager_xml} contour_interface)

kde4_add_library(recommendationsclient SHARED ${recommendationsclient_SRC}
)

set_target_properties(recommendationsclient PROPERTIES VERSION ${KDE_NON_GENERIC_LIB_VERSION} SOVERSION ${KDE_NON_GENERIC_LIB_SOVERSION})

target_link_libraries(
  recommendationsclient
  ${QT_QTCORE_LIBRARY}
  ${QT_QTGUI_LIBRARY}
  ${KDE4_KDECORE_LIBS}
  ${SOPRANO_LIBRARIES}
  ${NEPOMUK_LIBRARIES}
  ${NEPOMUK_QUERY_LIBRARIES}
  kworkspace
  QtLocation
)

set(recommendationsclient_LIB_HEADERS
    recommendation/recommendation.h
    recommendation/recommendationaction.h
    recommendation/recommendationsclient.h
    recommendation/recommendationsclient_export.h)

install(FILES ${recommendationsclient_LIB_HEADERS} DESTINATION ${INCLUDE_INSTALL_DIR}/ COMPONENT Devel)

install(TARGETS recommendationsclient EXPORT kdelibsLibraryTargets ${INSTALL_TARGETS_DEFAULT_ARGS})

