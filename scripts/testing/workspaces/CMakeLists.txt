cmake_minimum_required(VERSION 3.25)
project(FelogramWorkspaceTests LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
find_package(Qt6 REQUIRED COMPONENTS Core)
get_filename_component(src "${CMAKE_CURRENT_LIST_DIR}/../../../Telegram/SourceFiles" ABSOLUTE)
add_executable(test_felogram_workspaces
    ${src}/felogram/workspaces_model.cpp
    ${src}/felogram/workspaces_file.cpp
    ${src}/tests/test_felogram_workspaces.cpp)
target_include_directories(test_felogram_workspaces PRIVATE ${src})
target_link_libraries(test_felogram_workspaces PRIVATE Qt6::Core)
enable_testing()
add_test(NAME workspaces COMMAND test_felogram_workspaces)
