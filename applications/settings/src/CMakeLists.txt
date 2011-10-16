#add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)



#include_directories(
#    ${CMAKE_CURRENT_BINARY_DIR}
    #${CMAKE_CURRENT_BINARY_DIR}/ontologies
    #${CMAKE_CURRENT_SOURCE_DIR}/adblock
#   )


set(active-settings_SRCS
    main.cpp
    activesettings.cpp
    activesettingswindow.cpp
    view.cpp
    settingsmodulesitem.cpp
    settingsmodulesmodel.cpp
    settingsmodule.cpp
    settingsmoduleloader.cpp
)

KDE4_ADD_EXECUTABLE(active-settings ${active-settings_SRCS})

target_link_libraries(active-settings
    ${QT_QTDECLARATIVE_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_PLASMA_LIBS}
    kdeclarative
    #kactivities
)

install( TARGETS active-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
