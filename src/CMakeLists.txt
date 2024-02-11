# structure your project as a library for easy testing
add_library(rodeostat rodeostat.cpp)
target_include_directories(rodeostat PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_library(noesis STATIC IMPORTED)
set_target_properties(noesis PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES	${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Include
    IMPORTED_LOCATION           ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/NoesisGui/Bin/macos/Noesis.dylib
)

# main application code, links to library
add_executable(main main.cpp)
target_link_libraries(main PRIVATE rodeostat)
target_link_libraries(main PRIVATE noesis)