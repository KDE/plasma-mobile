find_package(PkgConfig REQUIRED)
pkg_check_modules(SYSTEMD systemd REQUIRED)
execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=systemduserunitdir systemd OUTPUT_VARIABLE SYSTEMD_USER_UNIT_DIR)
string(REGEX REPLACE "[ \t\n]+" "" SYSTEMD_USER_UNIT_DIR ${SYSTEMD_USER_UNIT_DIR})

macro(plasma_phone_install_service name)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${name}.service.cmake ${CMAKE_CURRENT_BINARY_DIR}/${name}.service)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${name}.service
            DESTINATION ${SYSTEMD_USER_UNIT_DIR})
endmacro()

plasma_phone_install_service(kactivitymanagerd)
plasma_phone_install_service(kded5)
plasma_phone_install_service(kdeinit5)
plasma_phone_install_service(kglobalaccel5)
plasma_phone_install_service(kuiserver5)
plasma_phone_install_service(plasma-phone-ui)
plasma_phone_install_service(plasma-phone)
