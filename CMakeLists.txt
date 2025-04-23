# Require CMake >= 3.7.x
cmake_minimum_required(VERSION 3.7.0 FATAL_ERROR)

# Set project name
project(sensu-enterprise-go
    LANGUAGES NONE)

# Project options
option(WITH_DEBUG_CMAKE "Enable on Sensu-specific CMake debugging statements."
    Off)

# CMake utilities
include(${CMAKE_SOURCE_DIR}/cmake/utils.cmake)

# Include version
include(${CMAKE_SOURCE_DIR}/cmake/version.cmake)

# Validate our objdir
sensu_validate_objdir()

include(${CMAKE_SOURCE_DIR}/cmake/preprocessing.cmake)
