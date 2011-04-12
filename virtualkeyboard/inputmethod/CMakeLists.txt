project(plasmainputcontext)

include(KDE4Defaults)

set(plasmainputcontext_SRCS
    plasmainputcontextplugin.cpp
    inputcontext.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_add_dbus_interface(plasmainputcontext_SRCS org.kde.PlasmaKeyboardShell.xml keyboard_interface)

qt4_automoc(${plasmainputcontext_SRCS})



#add_library(plasmainputcontextplugin SHARED ${plasmainputcontext_SRCS})
kde4_add_plugin(plasmainputcontextplugin ${plasmainputcontext_SRCS})
target_link_libraries(plasmainputcontextplugin ${QT_QTCORE_LIBRARY} ${QT_QTDBUS_LIBRARY}  ${QT_QTGUI_LIBRARY})

#This won't work with a local installation, but qt searches plugins only there
#FIXME: a place in the kde install prefix to install qt-only plugins?
install(TARGETS plasmainputcontextplugin DESTINATION ${QT_PLUGINS_DIR}/inputmethods/)
#install(TARGETS plasmainputcontextplugin DESTINATION ${PLUGIN_INSTALL_DIR}/inputmethods/)

#install(FILES plasmainputmethod.sh DESTINATION ${CMAKE_INSTALL_PREFIX}/env)

