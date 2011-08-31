set(apps_engine_SRCS
    runnerengine.cpp
    runnersource.cpp
    runnerservice.cpp
    runnerjob.cpp
)

kde4_add_plugin(plasma_engine_runner ${apps_engine_SRCS})
target_link_libraries(plasma_engine_runner ${KDE4_KDEUI_LIBS} ${KDE4_PLASMA_LIBS} ${KDE4_KIO_LIBS})

install(TARGETS plasma_engine_runner DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-org.kde.runner.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(FILES org.kde.runner.operations DESTINATION ${DATA_INSTALL_DIR}/plasma/services)
