project(dirmodel)

set(dirmodel_SRCS
    dirmodel.cpp
    dirmodelplugin.cpp
    )

qt4_automoc(${dirmodel_SRCS})

kde4_add_library(dirmodelplugin SHARED ${dirmodel_SRCS})
target_link_libraries(dirmodelplugin
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${KDE4_KIO_LIBS}
        )

install(TARGETS dirmodelplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/dirmodel)
install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/dirmodel)

#add_subdirectory(test)
