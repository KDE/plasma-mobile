install(FILES metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.phone.dialer.desktop)

include_directories(${TELEPATHY_QT5_INCLUDE_DIR})
# 

add_subdirectory(src)
