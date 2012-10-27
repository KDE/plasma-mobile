
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} ../../common )

set(active-aboutapp_SRCS
    main.cpp
    aboutapp.cpp
)

kde4_add_executable(active-aboutapp ${active-aboutapp_SRCS})

#find_package(ActiveApp REQUIRED)

target_link_libraries(active-aboutapp
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${QT_QTSCRIPT_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDECLARATIVE_LIBRARIES}
    activeapp
)

install(TARGETS active-aboutapp ${INSTALL_TARGETS_DEFAULT_ARGS} )

