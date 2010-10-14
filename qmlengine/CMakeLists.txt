set(declarative_appletscript_SRCS
    common/javascriptaddonpackagestructure.cpp
    common/scriptenvui.cpp
    plasmoid/abstractjsappletscript.cpp
    plasmoid/appletauthorization.cpp
    plasmoid/appletinterface.cpp
    plasmoid/declarativeappletscript.cpp
    plasmoid/engineaccess.cpp
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
    )

include_directories(${PHONON_INCLUDES} ${CMAKE_CURRENT_SOURCE_DIR}/common)

kde4_add_plugin(plasma_appletscript_declarative ${declarative_appletscript_SRCS})
target_link_libraries(plasma_appletscript_declarative
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KIO_LIBS}
    ${QT_QTSCRIPT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}

)


install(TARGETS plasma_appletscript_declarative DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES data/plasma-scriptengine-applet-declartive.desktop DESTINATION ${SERVICES_INSTALL_DIR})
