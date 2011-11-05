include(KDE4Defaults)
include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} )

add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)
find_package(Nepomuk REQUIRED)
find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")
include(SopranoAddOntology)

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

soprano_add_ontology(
    firstrun_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/kext.trig
    "KEXT" "Nepomuk::Vocabulary" "trig"
)

find_package(Nepomuk REQUIRED)
find_package(KActivities REQUIRED)

KDE4_ADD_EXECUTABLE(active-firstrun ${firstrun_SRCS})

target_link_libraries(active-firstrun
        ${KDE4_PLASMA_LIBS}
        ${NEPOMUK_LIBRARIES}
        ${NEPOMUK_QUERY_LIBRARIES}
        ${KACTIVITIES_LIBRARY}
)

install(TARGETS active-firstrun ${INSTALL_TARGETS_DEFAULT_ARGS} )
install(FILES adjust-time.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
