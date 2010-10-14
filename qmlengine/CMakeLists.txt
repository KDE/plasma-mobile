set(qml_appletscript_SRCS
    engineaccess.cpp
    plasmoid/abstractjsappletscript.cpp
    plasmoid/appletinterface.cpp
    plasmoid/appletauthorization.cpp
    plasmoid/qmlappletscript.cpp
    plasmoid/themedsvg.cpp
    simplebindings/bytearrayclass.cpp
    simplebindings/bytearrayprototype.cpp
    simplebindings/dataengine.cpp
    simplebindings/dataenginereceiver.cpp
    simplebindings/filedialogproxy.cpp
    simplebindings/i18n.cpp
    simplebindings/icon.cpp
    simplebindings/qscriptbookkeeping.cpp
    simplebindings/url.cpp
    common/scriptenvui.cpp
    common/javascriptaddonpackagestructure.cpp
    )

include_directories(${PHONON_INCLUDES} ${CMAKE_CURRENT_SOURCE_DIR}/common)

kde4_add_plugin(plasma_appletscript_qml ${qml_appletscript_SRCS})
target_link_libraries(plasma_appletscript_qml
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${QT_QTSCRIPT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}

)


install(TARGETS plasma_appletscript_qml DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-appletscript-qml.desktop DESTINATION ${SERVICES_INSTALL_DIR})
