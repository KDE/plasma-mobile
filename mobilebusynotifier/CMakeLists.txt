find_package(KDE4 REQUIRED)

include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   )

include_directories(${KDEBASE_WORKSPACE_SOURCE_DIR}/libs ${KDEBASE_WORKSPACE_SOURCE_DIR}/libs/kworkspace)


set(mobilebusynotifier_SRCS
    main.cpp
    busyapp.cpp
    busywidget.cpp
)


kde4_add_kdeinit_executable(mobilebusynotifier ${mobilebusynotifier_SRCS})

target_link_libraries(kdeinit_mobilebusynotifier ${KDE4_PLASMA_LIBS} )


install(TARGETS kdeinit_mobilebusynotifier DESTINATION ${LIB_INSTALL_DIR})
install(TARGETS mobilebusynotifier ${INSTALL_TARGETS_DEFAULT_ARGS})

install(FILES mobilebusynotifier.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})