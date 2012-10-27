set(krunner_apps_SRCS
    appsrunner.cpp
)

kde4_add_plugin(krunner_activeapps ${krunner_apps_SRCS})
target_link_libraries(krunner_activeapps ${KDE4_KIO_LIBS} ${KDE4_PLASMA_LIBS})

install(TARGETS krunner_activeapps DESTINATION ${PLUGIN_INSTALL_DIR} )

install(FILES plasma-runner-org.kde.active.apps.desktop DESTINATION ${SERVICES_INSTALL_DIR})

