project(alarmsengine)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${KDE4_INCLUDES} ${KDEPIMLIBS_INCLUDE_DIRS} ${QT_INCLUDES} )

find_package(Akonadi REQUIRED)
find_package (KdepimLibs REQUIRED)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS} ${KDEPIM_DEFINITIONS} ${AKONADI_DEFINITIONS})

set(alarmsengine_srcs
    alarmcontainer.cpp
    alarmsengine.cpp
    alarmsjob.cpp
    alarmsservice.cpp
)

kde4_add_plugin(plasma_engine_alarms ${alarmsengine_srcs})

target_link_libraries(plasma_engine_alarms
    ${KDE4_PLASMA_LIBS}
    ${KDEPIMLIBS_AKONADI_LIBS}
    #${KDE4_AKONADI_LIBS}
    ${KDE4_KPIMUTILS_LIBS}
    ${KDEPIMLIBS_KALARMCAL_LIBS}
    #${KDEPIMLIBS_AKONADI_KCAL_LIBS}
    ${KDEPIMLIBS_KCALCORE_LIBS}
)

install(TARGETS plasma_engine_alarms DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-alarms.desktop DESTINATION ${SERVICES_INSTALL_DIR})

install(FILES org.kde.alarms.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)