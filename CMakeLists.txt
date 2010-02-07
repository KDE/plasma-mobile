add_subdirectory(applets)
add_subdirectory(containments)
#add_subdirectory(dataengines)
add_subdirectory(desktoptheme)
find_package(Qt4 REQUIRED)

macro_log_feature(QT_QTDECLARATIVE_FOUND "QtDeclarative" "A Qt module to create user interface in a declarative language. Module is included in Qt 4.7." "http://qt.nokia.com" FALSE "" "The Plasma Mobile Qt Quick interface will not be build")

if (${QT_QTDECLARATIVE_FOUND})
  add_subdirectory(qml-research/plasma-mobile)
endif()
if(NOT WIN32)
add_subdirectory(shell)
endif(NOT WIN32)
