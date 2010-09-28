set(qml_appletscript_SRCS
    qmlappletscript.cpp
    appletinterface.cpp
    engineaccess.cpp
    plasmoid/appletauthorization.cpp
    plasmoid/themedsvg.cpp
    simplebindings/bytearrayclass.cpp
    simplebindings/bytearrayprototype.cpp
    simplebindings/dataengine.cpp
    simplebindings/filedialogproxy.cpp
    simplebindings/qscriptbookkeeping.cpp
    simplebindings/url.cpp
    common/scriptenv.cpp
    common/javascriptaddonpackagestructure.cpp
    ../common/qmlwidget.cpp
    )

set(qml_package_SRCS
    qmlpackage.cpp
    )

set(PLASMA_BINDINGS
   plasma_bindings
   )

include_directories(${PHONON_INCLUDES} ${CMAKE_CURRENT_SOURCE_DIR}/common)

kde4_add_plugin(plasma_appletscript_qml ${qml_appletscript_SRCS})
target_link_libraries(plasma_appletscript_qml
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
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
