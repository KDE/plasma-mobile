macro(satellite_install_dbus_service name)
    install(FILES ${name}.service
            DESTINATION ${CMAKE_INSTALL_FULL_SYSCONFDIR}/dbus-1/session.d)
endmacro()

satellite_install_dbus_service(org.kde.kde5)
satellite_install_dbus_service(org.kde.kglobalaccel)
satellite_install_dbus_service(org.kde.klauncher5)
satellite_install_dbus_service(org.kde.kuiserver)
