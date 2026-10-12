add_executable(test_felogram_workspaces EXCLUDE_FROM_ALL)
init_target(test_felogram_workspaces "(tests)")
target_include_directories(test_felogram_workspaces PRIVATE ${src_loc})
target_sources(test_felogram_workspaces PRIVATE
    ${src_loc}/felogram/workspaces_file.cpp
    ${src_loc}/felogram/workspaces_model.cpp
    ${src_loc}/tests/test_felogram_workspaces.cpp
)
target_link_libraries(test_felogram_workspaces PRIVATE Qt6::Core)
set_target_properties(test_felogram_workspaces PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)
