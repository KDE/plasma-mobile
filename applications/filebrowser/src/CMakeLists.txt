
#include_directories( ${KDE4_INCLUDES} ${QT_INCLUDES} ../../common)

set(active-filebrowser_SRCS
    main.cpp
    filebrowser.cpp
)

add_executable(active-filebrowser ${active-filebrowser_SRCS})

#find_package(ActiveApp REQUIRED)

target_link_libraries(active-filebrowser
 Qt5::Quick
 KF5::KIOCore
 KF5::Declarative
 KF5::I18n
 KF5::IconThemes
)

install(TARGETS active-filebrowser ${INSTALL_TARGETS_DEFAULT_ARGS})
