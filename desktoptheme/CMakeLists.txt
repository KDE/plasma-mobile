
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/metadata.desktop.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/metadata.desktop"
    @ONLY
)

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/metadata.desktop"
    DESTINATION ${PLASMA_DATA_INSTALL_DIR}/desktoptheme/breeze-mobile
)

FILE(GLOB widgets widgets/*.svg)
plasma_install_desktoptheme_svgs(breeze-mobile SUBPATH widgets FILES ${widgets})

