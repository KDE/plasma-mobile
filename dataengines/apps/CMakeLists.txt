set(apps_engine_SRCS
    appsengine.cpp
    appsource.cpp
    appservice.cpp
    appjob.cpp
)

kde4_add_plugin(plasma_engine_active_apps ${apps_engine_SRCS})
target_link_libraries(plasma_engine_active_apps ${KDE4_KDEUI_LIBS} ${KDE4_PLASMA_LIBS} ${KDE4_KIO_LIBS})

install(TARGETS plasma_engine_active_apps DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-org.kde.active.apps.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(FILES org.kde.active.apps.operations DESTINATION ${DATA_INSTALL_DIR}/plasma/services)
