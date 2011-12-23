project(settings)

set(settings_SRCS
    settingsmoduleloader.cpp
    settingsplugin.cpp
    settingsmodule.cpp
    )

qt4_automoc(${settings_SRCS})

kde4_add_library(settingsplugin SHARED ${settings_SRCS})
target_link_libraries(settingsplugin
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${KDE4_PLASMA_LIBS}
        )

install(TARGETS settingsplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/settings)
install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/settings)
