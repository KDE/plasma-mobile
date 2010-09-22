set(qml_appletscript_SRCS
    qmlappletscript.cpp
    appletinterface.cpp
    simplebindings/dataengine.cpp
    ../common/qmlwidget.cpp
    )

set(qml_package_SRCS
    qmlpackage.cpp
    )

set(PLASMA_BINDINGS
   plasma_bindings
   )

kde4_add_plugin(plasma_appletscript_qml ${qml_appletscript_SRCS})
target_link_libraries(plasma_appletscript_qml ${KDE4_PLASMA_LIBS}
    ${QT_QTSCRIPT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}
    ${PLASMA_BINDINGS}

)

kde4_add_plugin(plasma_package_qml ${qml_package_SRCS})
target_link_libraries(plasma_package_qml ${KDE4_PLASMA_LIBS}
    ${QT_QTSCRIPT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}
    ${PLASMA_BINDINGS}
)


install(TARGETS plasma_appletscript_qml DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-appletscript-qml.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(TARGETS plasma_package_qml DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-packagestructure-qml.desktop DESTINATION ${SERVICES_INSTALL_DIR})
