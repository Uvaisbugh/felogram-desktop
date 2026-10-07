# This file is part of Telegram Desktop,
# the official desktop application for the Telegram messaging service.
#
# For license and copyright information please follow this link:
# https://github.com/telegramdesktop/tdesktop/blob/master/LEGAL

cmake_minimum_required(VERSION 3.25...3.31)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include(cmake/validate_special_target.cmake)
include(cmake/version.cmake)
desktop_app_parse_version(Telegram/build/version)

if (NOT DEFINED CMAKE_CONFIGURATION_TYPES)
    set(configuration_types_init 1)
endif()

project(Telegram
    LANGUAGES C CXX
    VERSION ${desktop_app_version_cmake}
    DESCRIPTION "Felogram independent Telegram client"
    HOMEPAGE_URL "https://github.com/Uvaisbugh/felogram-desktop"
)

if (APPLE)
    enable_language(OBJC OBJCXX)
endif()

if (configuration_types_init
    AND CMAKE_CONFIGURATION_TYPES
    AND NOT MinSizeRel IN_LIST CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES};MinSizeRel" CACHE STRING "" FORCE)
endif()

set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT Telegram)

get_filename_component(third_party_loc "Telegram/ThirdParty" REALPATH)
get_filename_component(submodules_loc "Telegram" REALPATH)
get_filename_component(cmake_helpers_loc "cmake" REALPATH)

if (NOT DESKTOP_APP_USE_PACKAGED AND WIN32)
    set(Python3_EXECUTABLE ${CMAKE_CURRENT_SOURCE_DIR}/../ThirdParty/python/Scripts/python)
endif()

include(cmake/variables.cmake)
if (WIN32)
    set(DESKTOP_APP_DISABLE_AUTOUPDATE ON CACHE BOOL "Felogram updates require an independently verified service." FORCE)
    set(DESKTOP_APP_DISABLE_CRASH_REPORTS ON CACHE BOOL "Felogram does not use upstream crash reporting." FORCE)
endif()
include(cmake/nice_target_sources.cmake)
include(cmake/target_compile_options_if_exists.cmake)
include(cmake/target_link_frameworks.cmake)
include(cmake/target_link_options_if_exists.cmake)
include(cmake/init_target.cmake)
include(cmake/generate_target.cmake)
include(cmake/nuget.cmake)
include(cmake/validate_d3d_compiler.cmake)
include(cmake/target_prepare_qrc.cmake)

include(cmake/options.cmake)
include(cmake/external/qt/package.cmake)

set(desktop_app_skip_libs
    glibmm
    variant
)

add_subdirectory(cmake)
add_subdirectory(Telegram)

execute_process(COMMAND git rev-parse HEAD
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE FELOGRAM_SOURCE_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND git diff --quiet HEAD --
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE felogram_dirty)
if (felogram_dirty)
    string(APPEND FELOGRAM_SOURCE_REVISION "-dirty")
endif()
configure_file(Telegram/SourceFiles/core/felogram_build.h.in ${CMAKE_BINARY_DIR}/felogram/felogram_build.h @ONLY)
target_include_directories(Telegram PRIVATE ${CMAKE_BINARY_DIR}/felogram)
if (WIN32)
    set_target_properties(Telegram PROPERTIES
        OUTPUT_NAME Felogram
        COMPILE_PDB_NAME_DEBUG felogram-identity
    )
endif()
