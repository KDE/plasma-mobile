set(activenotifications-to-orgkdenotifications_SRCS activenotifications-to-orgkdenotifications.cpp)
kde4_add_executable(activenotifications-to-orgkdenotifications ${activenotifications-to-orgkdenotifications_SRCS})
target_link_libraries(activenotifications-to-orgkdenotifications ${KDE4_KDECORE_LIBS})
install(TARGETS activenotifications-to-orgkdenotifications DESTINATION ${LIB_INSTALL_DIR}/kconf_update_bin/)

install(FILES activenotifications-to-orgkdenotifications.upd DESTINATION ${KCONF_UPDATE_INSTALL_DIR})

