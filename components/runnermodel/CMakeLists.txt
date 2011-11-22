project(runnermodel)

set(runnermodel_SRCS
    runnermodel.cpp
    runnermodelplugin.cpp
    )

qt4_automoc(${runnermodel_SRCS})

kde4_add_library(runnermodelplugin SHARED ${runnermodel_SRCS})
target_link_libraries(runnermodelplugin
        ${QT_QTCORE_LIBRARY}
        ${QT_QTDECLARATIVE_LIBRARY}
        ${KDE4_PLASMA_LIBS}
        )

install(TARGETS runnermodelplugin DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/runnermodel)
install(FILES qmldir DESTINATION ${IMPORTS_INSTALL_DIR}/org/kde/runnermodel)

#add_subdirectory(test)
