project(phonebindings)

include(KDE4Defaults)

set(phonebindings_SRCS
    phonebindingsplugin.cpp
    phone.cpp
    )

INCLUDE_DIRECTORIES(
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_BINARY_DIR}
        ${KDE4_INCLUDES}
)

qt4_automoc(${phonebindings_SRCS})


add_library(phonebindingsplugin SHARED ${phonebindings_SRCS})
target_link_libraries(phonebindingsplugin ${QT_QTCORE_LIBRARY} ${QT_QTDBUS_LIBRARY}  ${QT_QTGUI_LIBRARY} ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDECORE_LIBRARY})

install(TARGETS phonebindingsplugin DESTINATION ${QT_INCLUDE_DIR}/../imports/org/kde/plasma/phone)
#install(TARGETS phonebindingsplugin DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/phone)
install(FILES qmldir DESTINATION ${QT_INCLUDE_DIR}/../imports/org/kde/plasma/phone)
#install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/org/kde/plasma/phone)