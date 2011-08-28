add_definitions(-DDISABLE_NEPOMUK_LEGACY=1)


find_package(Nepomuk REQUIRED)

find_package(Soprano)
  macro_log_feature(Soprano_FOUND "Soprano" "Semantic Desktop Storing" "http://soprano.sourceforge.net"
  TRUE "${SOPRANO_MIN_VERSION}" "Soprano is needed for Nepomuk")

include(SopranoAddOntology)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/ontologies
    #${CMAKE_CURRENT_SOURCE_DIR}/..
   )

add_subdirectory(ontologies)

set(active-webbrowser_SRCS
    main.cpp
    activewebbrowser.cpp
    activebrowserwindow.cpp
    kdeclarativewebview.cpp
    completionitem.cpp
    completionmodel.cpp
    view.cpp
)

KDE4_ADD_EXECUTABLE(active-webbrowser ${active-webbrowser_SRCS})

target_link_libraries(active-webbrowser
    ${QT_QTWEBKIT_LIBRARY}
    ${QT_QTDECLARATIVE_LIBRARY}
    ${QT_QTOPENGL_LIBRARY}
    ${KDE4_KDEUI_LIBS}
    ${KDE4_KIO_LIBS}
    ${KDE4_PLASMA_LIBS}
    ${KDE4_KDEWEBKIT_LIBRARY}
    kdeclarative
    kactivities
    ontologies
)

install( TARGETS active-webbrowser ${INSTALL_TARGETS_DEFAULT_ARGS} )
