include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES})

set(mobileprofile_engine_SRCS
    mobileprofileengine.cpp
    mobileprofilesource.cpp
)

kde4_add_plugin(plasma_engine_mobileprofile ${mobileprofile_engine_SRCS})
target_link_libraries(plasma_engine_mobileprofile ${KDE4_PLASMA_LIBS})

install(TARGETS plasma_engine_mobileprofile DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-mobileprofile.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

