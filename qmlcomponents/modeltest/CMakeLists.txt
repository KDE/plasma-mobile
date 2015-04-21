
set(applicationlistmodeltest_SRCS
    main.cpp
    modeltest.cpp
    ../applicationlistmodel.cpp
    )

add_executable(applicationlistmodeltest ${applicationlistmodeltest_SRCS})
target_link_libraries(applicationlistmodeltest
                        Qt5::Core
                        Qt5::Test
                        Qt5::Widgets
                        KF5::Service
                        )

