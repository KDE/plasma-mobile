add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)


find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")

include(SopranoAddOntology)

include_directories(
    ${CMAKE_BINARY_DIR}/dataengines/metadata/ontologies
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/ontologies
    ${CMAKE_CURRENT_SOURCE_DIR}/adblock
   )

add_subdirectory(ontologies)

set(active-webbrowser_SRCS
    main.cpp
    activewebbrowser.cpp
    activebrowserwindow.cpp
    kdeclarativewebview.cpp
    completionitem.cpp
    completionmodel.cpp
    nepomukhelper.cpp
    history.cpp
    view.cpp

    networkaccessmanager.cpp
    adblock/adblockhostmatcher.cpp
    adblock/adblockmanager.cpp
    adblock/adblocknetworkreply.cpp
    adblock/adblockrule.cpp
    adblock/adblockrulefallbackimpl.cpp
    adblock/adblockrulenullimpl.cpp
    adblock/adblockruletextmatchimpl.cpp
    #adblock/adblockwidget.cpp
)

soprano_add_ontology( webbrowser_SRCS
  "${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/nuao.trig"
  "NUAO"
  "Nepomuk::Vocabulary"
  "trig")

soprano_add_ontology( SRCS
  "${SHAREDDESKTOPONTOLOGIES_ROOT_DIR}/nepomuk/ndo.trig"
  "NDO"
  "Nepomuk::Vocabulary"
  "trig")

#KDE4_ADD_UI_FILES( active-webbrowser_SRCS
#    adblock/settings_adblock.ui
#)

KDE4_ADD_EXECUTABLE(active-webbrowser ${active-webbrowser_SRCS})

target_link_libraries(active-webbrowser
    ${QT_QTWEBKIT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KDEWEBKIT_LIBRARY}
    ${NEPOMUK_LIBRARIES}
    ${NEPOMUK_QUERY_LIBRARIES}
    ${KACTIVITIES_LIBRARY}
    kdeclarative
    ontologies
    nepomukdatamanagement # enable if we want to ue SimpleResource instead of Resource
)

install(FILES infopage.html DESTINATION ${DATA_INSTALL_DIR}/active-webbrowser )

install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )
