# structure your project as a library for easy testing
add_library(rodeostat RodeoStat/rodeostat.cpp RodeoStat/graphics.cpp RodeoStat/control.cpp RodeoStat/clock.cpp RodeoStat/score.cpp RodeoStat/contestant.cpp)
target_include_directories(rodeostat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/RodeoStat)

add_library(app_xaml App.xaml.cpp)
target_include_directories(app_xaml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_library(mainwindow_xaml MainWindow.xaml.cpp)
target_include_directories(mainwindow_xaml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_library(viewmodel ViewModel.cpp)
target_include_directories(viewmodel PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(app_xaml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin)


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

# Embedding XAML files into C style array headers
include(bin2h.cmake)
message("Embedding 'App.xaml' into header file '/Resources/Bin/App.xaml.bin.h")
bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/App.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/App.xaml.bin.h VARIABLE_NAME App_xaml REPLACE)
message("Embedding 'MainWindow.xaml' into header file '/Resources/Bin/MainWindow.xaml.bin.h")
bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/MainWindow.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/MainWindow.xaml.bin.h VARIABLE_NAME MainWindow_xaml REPLACE)
message("Embedding 'Resources.xaml' into header file '/Resources/Bin/Resources.xaml.bin.h")
bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/Resources.xaml.bin.h VARIABLE_NAME Resources_xaml REPLACE)

# message("Embedding 'SegMDL2.ttf' into header file '/Resources/Bin/SegMDL2.ttf.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/Fonts/SegMDL2.ttf HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/SegMDL2.ttf.bin.h VARIABLE_NAME SegMDL2_ttf REPLACE)
# message("Embedding 'NotoSans-Regular.ttf' into header file '/Resources/Bin/NotoSans-Regular.ttf.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/Fonts/NotoSans-Regular.ttf HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NotoSans-Regular.ttf.bin.h VARIABLE_NAME NotoSans_Regular_ttf REPLACE)

# message("Embedding 'NoesisTheme.Styles.xaml' into header file '/Resources/Bin/NoesisTheme.Styles.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.Styles.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.Styles.xaml.bin.h VARIABLE_NAME NoesisTheme_styles_xaml REPLACE)
# message("Embedding 'NoesisTheme.Fonts.xaml' into header file '/Resources/Bin/NoesisTheme.Fonts.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.Fonts.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.Fonts.xaml.bin.h VARIABLE_NAME NoesisTheme_fonts_xaml REPLACE)
# message("Embedding 'NoesisTheme.DarkRed.xaml' into header file '/Resources/Bin/NoesisTheme.DarkRed.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.DarkRed.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.DarkRed.xaml.bin.h VARIABLE_NAME NoesisTheme_darkred_xaml REPLACE)
# message("Embedding 'NoesisTheme.Styles.xaml' into header file '/Resources/Bin/NoesisTheme.Styles.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.Styles.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.Styles.xaml.bin.h VARIABLE_NAME NoesisTheme_styles_xaml REPLACE)
# message("Embedding 'NoesisTheme.Colors.Dark.xaml' into header file '/Resources/Bin/NoesisTheme.Colors.Dark.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.Colors.Dark.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.Colors.Dark.xaml.bin.h VARIABLE_NAME NoesisTheme_colors_dark_xaml REPLACE)
# message("Embedding 'NoesisTheme.Brushes.DarkRed.xaml' into header file '/Resources/Bin/NoesisTheme.Brushes.DarkRed.xaml.bin.h")
# bin2h(SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Themes/NoesisTheme.Brushes.DarkRed.xaml HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Resources/Bin/NoesisTheme.Brushes.DarkRed.xaml.bin.h VARIABLE_NAME NoesisTheme_brushes_darkred_xaml REPLACE)
# need to re-make when changes made to files

# main application code, links to library
add_executable(main main.cpp)
target_link_libraries(main PRIVATE rodeostat)
target_link_libraries(main PRIVATE noesis)
target_link_libraries(main PRIVATE noesisapp)
target_link_libraries(main PRIVATE app_xaml)
target_link_libraries(main PRIVATE mainwindow_xaml)
target_link_libraries(main PRIVATE viewmodel)