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
include src/CMakeFiles/mainwindow_xaml.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include src/CMakeFiles/mainwindow_xaml.dir/compiler_depend.make

# Include the progress variables for this target.
include src/CMakeFiles/mainwindow_xaml.dir/progress.make

# Include the compile flags for this target's objects.
include src/CMakeFiles/mainwindow_xaml.dir/flags.make

src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o: src/CMakeFiles/mainwindow_xaml.dir/flags.make
src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/MainWindow.xaml.cpp
src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o: src/CMakeFiles/mainwindow_xaml.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o -MF CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o.d -o CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o -c /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/MainWindow.xaml.cpp

src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.i"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/MainWindow.xaml.cpp > CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.i

src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.s"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && /Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/MainWindow.xaml.cpp -o CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.s

# Object files for target mainwindow_xaml
mainwindow_xaml_OBJECTS = \
"CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o"

# External object files for target mainwindow_xaml
mainwindow_xaml_EXTERNAL_OBJECTS =

src/libmainwindow_xaml.dylib: src/CMakeFiles/mainwindow_xaml.dir/MainWindow.xaml.cpp.o
src/libmainwindow_xaml.dylib: src/CMakeFiles/mainwindow_xaml.dir/build.make
src/libmainwindow_xaml.dylib: src/libviewmodel.dylib
src/libmainwindow_xaml.dylib: src/librodeostat_lib.dylib
src/libmainwindow_xaml.dylib: src/libapp_xaml.dylib
src/libmainwindow_xaml.dylib: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Libraries/NoesisGui/Bin/macos/NoesisApp.dylib
src/libmainwindow_xaml.dylib: /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src/Libraries/NoesisGui/Bin/macos/Noesis.dylib
src/libmainwindow_xaml.dylib: src/CMakeFiles/mainwindow_xaml.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX shared library libmainwindow_xaml.dylib"
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/mainwindow_xaml.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/CMakeFiles/mainwindow_xaml.dir/build: src/libmainwindow_xaml.dylib
.PHONY : src/CMakeFiles/mainwindow_xaml.dir/build

src/CMakeFiles/mainwindow_xaml.dir/clean:
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src && $(CMAKE_COMMAND) -P CMakeFiles/mainwindow_xaml.dir/cmake_clean.cmake
.PHONY : src/CMakeFiles/mainwindow_xaml.dir/clean

src/CMakeFiles/mainwindow_xaml.dir/depend:
	cd /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/src /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src /Users/benschaser/Documents/College_Work/Senior_24/Semester_2/CS-Capstone/RodeoStat_Demo_Noesis/build/src/CMakeFiles/mainwindow_xaml.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/CMakeFiles/mainwindow_xaml.dir/depend

