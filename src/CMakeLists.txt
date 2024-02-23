# structure your project as a library for easy testing
add_library(rodeostat RodeoStat/rodeostat.cpp)
target_include_directories(rodeostat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/RodeoStat)

add_library(app_xaml App.xaml.cpp)
target_include_directories(app_xaml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_library(mainwindow_xaml MainWindow.xaml.cpp)
target_include_directories(mainwindow_xaml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_library(viewmodel ViewModel.cpp)
target_include_directories(viewmodel PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


add_library(noesis SHARED IMPORTED)
set_target_properties(noesis PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES	${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Include
    IMPORTED_LOCATION           ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Bin/macos/Noesis.dylib
)

add_library(noesisapp SHARED IMPORTED)
set_target_properties(noesisapp PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES	${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Include/NsApp
    IMPORTED_LOCATION           ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Bin/macos/NoesisApp.dylib
)

find_package(SFML REQUIRED system window graphics network audio)
target_link_libraries(rodeostat sfml-system sfml-window sfml-graphics sfml-network sfml-audio)


target_link_libraries(app_xaml noesis)
target_link_libraries(mainwindow_xaml noesis)
target_link_libraries(viewmodel noesis)



include(${CMAKE_CURRENT_SOURCE_DIR}/AddIconToBinary.cmake)
AddIconToBinary(SOURCE_FILES ICONS ${CMAKE_CURRENT_SOURCE_DIR}/Resources/icons/rs.ico ${CMAKE_CURRENT_SOURCE_DIR}/Resources/icons/rs.icns)
# main application code, links to library
add_executable(main main.cpp)
target_link_libraries(main PRIVATE rodeostat)
target_link_libraries(main PRIVATE noesis)
target_link_libraries(main PRIVATE noesisapp)
target_link_libraries(main PRIVATE app_xaml)
target_link_libraries(main PRIVATE mainwindow_xaml)
target_link_libraries(main PRIVATE viewmodel)