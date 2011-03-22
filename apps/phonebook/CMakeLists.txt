set(KDE_MIN_VERSION 4.6.0)
find_package(KDE4 REQUIRED)

include (KDE4Defaults)
include_directories( ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${KDE4_INCLUDES})

set(phonebook_SRCS main.cpp phonebook.cpp declarativecontactmodel.cpp)

kde4_add_executable(phonebook ${phonebook_SRCS})

target_link_libraries(phonebook kdeclarative akonadi-kabc akonadi-kde akonadi-contact kabc ofono-qt ${QT_QTSCRIPT_LIBRARY} ${QT_QTDECLARATIVE_LIBRARY} ${KDE4_KDEUI_LIBS})

install(TARGETS phonebook ${INSTALL_TARGETS_DEFAULT_ARGS} )

