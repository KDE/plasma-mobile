set(runnermodeltest_SRCS
    main.cpp
    dynamictreemodel.cpp
    modeltest.cpp
    ../runnermodel.cpp
    )

qt4_automoc(${runnermodeltest_SRCS})
#kde4_add_library(datamodelsplugin SHARED ${datamodels_SRCS})
kde4_add_executable(runnermodeltest ${runnermodeltest_SRCS})
target_link_libraries(runnermodeltest ${QT_QTTEST_LIBRARY} ${KDE4_PLASMA_LIBS})

