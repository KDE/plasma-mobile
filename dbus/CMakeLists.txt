macro(plasma_phone_install_dbus_service name)
    install(FILES ${name}.service
            DESTINATION ${CMAKE_INSTALL_FULL_SYSCONFDIR}/dbus-1/session.d)
endmacro()

plasma_phone_install_dbus_service(org.kde.kde5)
plasma_phone_install_dbus_service(org.kde.kglobalaccel)
plasma_phone_install_dbus_service(org.kde.klauncher5)
plasma_phone_install_dbus_service(org.kde.kuiserver)
