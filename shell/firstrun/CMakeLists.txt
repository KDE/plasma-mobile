include(KDE4Defaults)
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

include_directories(
   ${CMAKE_CURRENT_BINARY_DIR}
   ${CMAKE_CURRENT_BINARY_DIR}/ontologies
   ${CMAKE_CURRENT_SOURCE_DIR}/adblock
   )

set(firstrun_SRCS
    main.cpp
    app.cpp
    firstrun.cpp
)

add_kao_ontology(firstrun_SRCS)

find_package(Nepomuk REQUIRED)
#find_package(KActivities REQUIRED)

KDE4_ADD_EXECUTABLE(active-firstrun ${firstrun_SRCS})

target_link_libraries(active-firstrun
        ${KDE4_PLASMA_LIBS}
        ${NEPOMUK_LIBRARIES}
        ${NEPOMUK_QUERY_LIBRARIES}
        ${KACTIVITIES_LIBRARY}
)

install(TARGETS active-firstrun ${INSTALL_TARGETS_DEFAULT_ARGS} )
install(FILES adjust-time.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
