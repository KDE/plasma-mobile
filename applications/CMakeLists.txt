#add_subdirectory(common)

#add_subdirectory(about)
add_subdirectory(settings)
if (${KF5Baloo_FOUND})
    add_subdirectory(filebrowser)
endif()
#add_subdirectory(webbrowser)
#add_subdirectory(widgetstrip)
