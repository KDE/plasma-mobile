project(contourd)

# This should be REQUIRED once we get rid of the hack below
find_package(QtMobility)

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
  ${QT_INCLUDE_DIR}/QtMobility
  ${QT_INCLUDE_DIR}/QtMobility/QtMobility
#this uses the cmake macro
  ${QTMOBILITY_INCLUDE_DIR}
)

configure_file(
  config-features.h.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/config-features.h
)

add_subdirectory(recommendation/plugins)

set(recommendationmanager_SRC
  recommendation/RecommendationManager.cpp
  recommendation/RecommendationEngine.cpp
  recommendation/RecommendationItem.cpp
  recommendation/RecommendationScriptEngine.cpp

  recommendation/sensors/dbus/DBusSensor.cpp

  location/LocationManager.cpp
  location/network-engines/NetworkNotifier.cpp
  location/network-engines/dummy/DummyNetworkNotifier.cpp
  location/network-engines/connman/ConnmanNetworkNotifier.cpp
  location/network-engines/connman/connman-manager.cpp
  location/network-engines/connman/connman-service.cpp

  main.cpp
)

qt4_add_dbus_adaptor(
  recommendationmanager_SRC recommendation/org.kde.contour.RecommendationManager.xml
  recommendation/RecommendationManager.h Contour::RecommendationManager
)

qt4_add_dbus_adaptor(
  recommendationmanager_SRC location/org.kde.contour.LocationManager.xml
  location/LocationManager.h Contour::LocationManager
)

qt4_add_dbus_adaptor(
  recommendationmanager_SRC location/network-engines/dummy/org.kde.LocationManager.DummyNetworkNotifier.xml
  location/network-engines/dummy/DummyNetworkNotifier.h DummyNetworkNotifier
)

qt4_add_dbus_adaptor(
  recommendationmanager_SRC location/network-engines/connman/org.kde.LocationManager.ConnmanNetworkNotifier.xml
  location/network-engines/connman/ConnmanNetworkNotifier.h ConnmanNetworkNotifier
)

find_file(kext_onto_src kext.trig PATH_SUFFIXES "ontology/kde" PATHS ${CMAKE_INSTALL_PREFIX}/share ENV XDG_DATA_DIRS)

soprano_add_ontology(recommendationmanager_SRC
    ${kext_onto_src}
    "KExt" "Nepomuk::Vocabulary" "trig"
    )

soprano_add_ontology(recommendationmanager_SRC
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/nao.trig
    "NAO" "Nepomuk::Vocabulary" "trig"
    )

soprano_add_ontology(recommendationmanager_SRC
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nie.trig
    "NIE" "Nepomuk::Vocabulary" "trig"
    )

soprano_add_ontology(recommendationmanager_SRC
    ${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nie/nco.trig
    "NCO" "Nepomuk::Vocabulary" "trig"
    )

########################################################################
set(ADDITIONAL_LINK_LIBRARIES)

set(recommendationmanager_SRC
    ${recommendationmanager_SRC}
    location/network-engines/solid/SolidNetworkNotifier.cpp
    )

set(ADDITIONAL_LINK_LIBRARIES
    ${ADDITIONAL_LINK_LIBRARIES}
    ${KDE4_SOLID_LIBS}
    )

########################################################################

kde4_add_executable(contour
  ${recommendationmanager_SRC}
)

target_link_libraries(
  contour
  ${QT_QTCORE_LIBRARY}
  ${QT_QTSCRIPT_LIBRARY}
  ${KDE4_KDECORE_LIBS}
  ${KDE4_KIO_LIBS}
  ${SOPRANO_LIBRARIES}
  ${NEPOMUK_LIBRARIES}
  ${NEPOMUK_QUERY_LIBRARIES}
  ${ADDITIONAL_LINK_LIBRARIES}
  kworkspace
  solidcontrol
  solidcontrolifaces
  QtLocation
  QtContacts
  QtSensors
)

install(FILES
    contour-recommendationengine.desktop
    DESTINATION ${SERVICETYPES_INSTALL_DIR}
    )

install(FILES
    contour-recommendationengine-qtscript.desktop
    DESTINATION ${SERVICETYPES_INSTALL_DIR}
    )

install(FILES
    contour.desktop DESTINATION
    ${AUTOSTART_INSTALL_DIR}
    )

install(TARGETS
    contour
    ${INSTALL_TARGETS_DEFAULT_ARGS}
    )

message("AAAAAAAA ${DATA_INSTALL_DIR}")

install(FILES
    location/network-engines/connman/org.kde.LocationManager.ConnmanWatcher.py

    DESTINATION
    ${DATA_INSTALL_DIR}/locationmanager/

    PERMISSIONS
    OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE
    WORLD_READ WORLD_EXECUTE
    )

