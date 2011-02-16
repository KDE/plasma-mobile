find_package(KDE4 REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   )

include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


set(plasma-keyboardcontainer_SRCS
    main.cpp
    plasmaapp.cpp
    keyboardcorona.cpp
    keyboardview.cpp
)

set(keyboard_dbusXML org.kde.PlasmaKeyboardShell.xml)
qt4_add_dbus_adaptor(plasma-keyboardcontainer_SRCS ${keyboard_dbusXML} plasmaapp.h PlasmaApp)

kde4_add_kdeinit_executable(plasma-keyboardcontainer ${plasma-keyboardcontainer_SRCS})

target_link_libraries(kdeinit_plasma-keyboardcontainer ${KDE4_PLASMA_LIBS} kworkspace ${KDE4_KIO_LIBS} ${X11_LIBRARIES} ${KDE4_KFILE_LIBS} )


install(TARGETS kdeinit_plasma-keyboardcontainer DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS plasma-keyboardcontainer ${INSTALL_TARGETS_DEFAULT_ARGS})

