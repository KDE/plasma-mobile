
include(KDE4Defaults)

set(mobile_launcher_SRCS
    mobilelauncher.cpp
    models/appmodel.cpp
    models/commonmodel.cpp
    models/krunnermodel.cpp
    models/standarditemfactory.cpp
    )

kde4_add_plugin(plasma_containment_activelauncher ${mobile_launcher_SRCS})
target_link_libraries(plasma_containment_activelauncher ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KIO_LIBS} )

install(DIRECTORY qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma-mobile/containments/mobilelauncher PATTERN .svn EXCLUDE)
install(TARGETS plasma_containment_activelauncher DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-containment-org.kde.active.launcher.desktop DESTINATION ${SERVICES_INSTALL_DIR})
