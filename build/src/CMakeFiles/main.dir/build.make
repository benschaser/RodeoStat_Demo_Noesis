# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.25

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/homebrew/Cellar/cmake/3.25.2/bin/cmake

# The command to remove a file.
RM = /opt/homebrew/Cellar/cmake/3.25.2/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build

# Include any dependencies generated for this target.
include src/CMakeFiles/main.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include src/CMakeFiles/main.dir/compiler_depend.make

# Include the progress variables for this target.
include src/CMakeFiles/main.dir/progress.make

# Include the compile flags for this target's objects.
include src/CMakeFiles/main.dir/flags.make

src/main.app/Contents/Icons/rs.icns: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Resources/Icons/rs.icns
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Copying OS X content src/main.app/Contents/Icons/rs.icns"
	$(CMAKE_COMMAND) -E copy /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Resources/Icons/rs.icns src/main.app/Contents/Icons/rs.icns

src/CMakeFiles/main.dir/main.cpp.o: src/CMakeFiles/main.dir/flags.make
src/CMakeFiles/main.dir/main.cpp.o: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/main.cpp
src/CMakeFiles/main.dir/main.cpp.o: src/CMakeFiles/main.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object src/CMakeFiles/main.dir/main.cpp.o"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT src/CMakeFiles/main.dir/main.cpp.o -MF CMakeFiles/main.dir/main.cpp.o.d -o CMakeFiles/main.dir/main.cpp.o -c /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/main.cpp

src/CMakeFiles/main.dir/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/main.dir/main.cpp.i"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/main.cpp > CMakeFiles/main.dir/main.cpp.i

src/CMakeFiles/main.dir/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/main.dir/main.cpp.s"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/main.cpp -o CMakeFiles/main.dir/main.cpp.s

# Object files for target main
main_OBJECTS = \
"CMakeFiles/main.dir/main.cpp.o"

# External object files for target main
main_EXTERNAL_OBJECTS =

src/main.app/Contents/MacOS/main: src/CMakeFiles/main.dir/main.cpp.o
src/main.app/Contents/MacOS/main: src/CMakeFiles/main.dir/build.make
src/main.app/Contents/MacOS/main: src/libmainwindow_xaml.dylib
src/main.app/Contents/MacOS/main: src/libviewmodel.dylib
src/main.app/Contents/MacOS/main: src/librodeostat.dylib
src/main.app/Contents/MacOS/main: src/libapp_xaml.dylib
src/main.app/Contents/MacOS/main: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Libraries/NoesisGui/Bin/macos/Noesis.dylib
src/main.app/Contents/MacOS/main: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Libraries/NoesisGui/Bin/macos/NoesisApp.dylib
src/main.app/Contents/MacOS/main: src/CMakeFiles/main.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable main.app/Contents/MacOS/main"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/main.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/CMakeFiles/main.dir/build: src/main.app/Contents/MacOS/main
src/CMakeFiles/main.dir/build: src/main.app/Contents/Icons/rs.icns
.PHONY : src/CMakeFiles/main.dir/build

src/CMakeFiles/main.dir/clean:
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && $(CMAKE_COMMAND) -P CMakeFiles/main.dir/cmake_clean.cmake
.PHONY : src/CMakeFiles/main.dir/clean

src/CMakeFiles/main.dir/depend:
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src/CMakeFiles/main.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/CMakeFiles/main.dir/depend

