# Project Needs a name ofcourse
project(mobilesystemtray)

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
set(mobilesystemtray_SRCS

    core/manager.cpp
    core/protocol.cpp
    core/task.cpp

    #protocols/fdo/fdoprotocol.cpp
    #protocols/fdo/fdotask.cpp
    #FIXME: we should find another way to achieve that
    #protocols/fdo/fdonotification.cpp
    #protocols/fdo/fdographicswidget.cpp
    #protocols/fdo/fdoselectionmanager.cpp
    #protocols/fdo/x11embedcontainer.cpp
    #protocols/fdo/x11embeddelegate.cpp
    #protocols/fdo/x11embedpainter.cpp

    protocols/plasmoid/plasmoidtaskprotocol.cpp
    protocols/plasmoid/plasmoidtask.cpp

    protocols/dbussystemtray/dbussystemtraytask.cpp
    protocols/dbussystemtray/dbussystemtrayprotocol.cpp
    protocols/dbussystemtray/dbussystemtraywidget.cpp

    ui/applet.cpp
    )

# Now make sure all files get to the right place
kde4_add_plugin(plasma_applet_mobilesystemtray ${mobilesystemtray_SRCS})
target_link_libraries(plasma_applet_mobilesystemtray
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS})

install(TARGETS plasma_applet_mobilesystemtray
        DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-applet-mobilesystemtray.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})