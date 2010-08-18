# Project Needs a name ofcourse
project(fakesignal)

# Find the required Libaries
find_package(KDE4 REQUIRED)
include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   )

# We add our source code here
set(fakesignal_SRCS

    fakesignal.cpp
)

# Now make sure all files get to the right place
kde4_add_plugin(plasma_applet_fakesignal ${fakesignal_SRCS})
target_link_libraries(plasma_applet_fakesignal
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS})

install(TARGETS plasma_applet_fakesignal
        DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-applet-fakesignal.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})

#install(FILES network.svgz DESTINATION ${DATA_INSTALL_DIR}/desktoptheme/default/icons/) 