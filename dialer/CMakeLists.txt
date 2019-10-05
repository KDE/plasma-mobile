install(FILES metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.phone.dialer.desktop)

include_directories(${TELEPATHY_QT5_INCLUDE_DIR})
include_directories(${Qofono_INCLUDE_DIRS})

add_subdirectory(src)
