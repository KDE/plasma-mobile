find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
kde4_install_icons( ${ICON_INSTALL_DIR} )

install( FILES location.svgz location-changed.svgz location-unknown.svgz
    DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/default/icons/ )

