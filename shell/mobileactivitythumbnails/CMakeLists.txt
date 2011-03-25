set(mobileactivitythumbnails_SRCS
    mobileactivitythumbnails.cpp
)

kde4_add_plugin(plasma_dataengine_mobileactivitythumbnails ${mobileactivitythumbnails_SRCS})
target_link_libraries(plasma_dataengine_mobileactivitythumbnails ${KDE4_PLASMA_LIBS} kworkspace)

install(TARGETS plasma_dataengine_mobileactivitythumbnails DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-dataengine-mobileactivitythumbnails.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

