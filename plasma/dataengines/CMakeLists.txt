project(nepomukmobile-user)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

find_package(KDE4 REQUIRED)
include (KDE4Defaults)
include(MacroLibrary)
include(MacroOptionalDependPackage)

add_subdirectory(dataengine)


