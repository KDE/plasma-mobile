install(PROGRAMS kwinwrapper DESTINATION ${BIN_INSTALL_DIR})

configure_file(plasma-mobile.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/plasma-mobile.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)
