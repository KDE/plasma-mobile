
project(mobilemousetheme)

file(GLOB icon_files theme/cursors/*)

install(FILES theme/index.theme DESTINATION ${ICON_INSTALL_DIR}/plasmamobilemouse/)
install(FILES ${icon_files} DESTINATION ${ICON_INSTALL_DIR}/plasmamobilemouse/cursors/)

