find_package(PkgConfig REQUIRED)
pkg_check_modules(SYSTEMD systemd REQUIRED)
execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=systemduserunitdir systemd OUTPUT_VARIABLE SYSTEMD_USER_UNIT_DIR)
string(REGEX REPLACE "[ \t\n]+" "" SYSTEMD_USER_UNIT_DIR ${SYSTEMD_USER_UNIT_DIR})

macro(satellite_install_service name)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${name}.service.cmake ${CMAKE_CURRENT_BINARY_DIR}/${name}.service)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${name}.service
            DESTINATION ${SYSTEMD_USER_UNIT_DIR})
endmacro()

satellite_install_service(kded5)
satellite_install_service(kdeinit5)
satellite_install_service(plasma-phone-compositor)
satellite_install_service(plasma-phone-ui)
