set(mobiledesktop_SRCS
    mobiledesktop.cpp
    appletscontainer.cpp
    )

kde4_add_plugin(plasma_containment_mobiledesktop ${mobiledesktop_SRCS})
target_link_libraries(plasma_containment_mobiledesktop ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY} )

install(TARGETS plasma_containment_mobiledesktop DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-containment-mobiledesktop.desktop DESTINATION ${SERVICES_INSTALL_DIR})
