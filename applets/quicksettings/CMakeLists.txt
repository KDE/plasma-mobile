set(quicksettings_SRCS
    quicksettings.cpp
)

add_library(plasma_applet_quicksettings MODULE ${quicksettings_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_quicksettings package/metadata.desktop)

target_link_libraries(plasma_applet_quicksettings
                      Qt5::Gui
                      KF5::Plasma
                      KF5::I18n)


install(TARGETS plasma_applet_quicksettings DESTINATION ${PLUGIN_INSTALL_DIR})
#install(FILES plasma-quicksettings-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.phone.quicksettings)

