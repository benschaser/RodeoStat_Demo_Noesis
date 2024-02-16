# structure your project as a library for easy testing
add_library(rodeostat rodeostat.cpp)
target_include_directories(rodeostat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_library(noesis STATIC IMPORTED)
set_target_properties(noesis PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES	${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Include
    IMPORTED_LOCATION           ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Bin/macos/Noesis.dylib
)
add_library(sfml STATIC IMPORTED)
set_target_properties(sfml PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES	${CMAKE_CURRENT_SOURCE_DIR}/Libraries/SFML/Include
    IMPORTED_LOCATION           ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/SFML/lib
)

# main application code, links to library
add_executable(main main.cpp)
target_link_libraries(main PRIVATE rodeostat)
target_link_libraries(main PRIVATE noesis)