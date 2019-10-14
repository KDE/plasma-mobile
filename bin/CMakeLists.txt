configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plasma-phone.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-phone)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/plasma-phone
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_EXECUTE WORLD_READ GROUP_EXECUTE GROUP_READ
        DESTINATION ${BIN_INSTALL_DIR})
install(PROGRAMS kwinwrapper DESTINATION ${BIN_INSTALL_DIR})

configure_file(plasma-mobile.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)
