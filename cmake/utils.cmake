function(sensu_cmake_debug _dbg_mesg)
    if (WITH_DEBUG_CMAKE)
        message(STATUS "sensu_cmake_debug: ${_dbg_mesg}")
    endif()
endfunction()

function(sensu_check_dep _required_dep)
    if (${${_required_dep}} STREQUAL "${_required_dep}-NOTFOUND")
        message(FATAL_ERROR "Required tool ${_required_dep} missing; install and/or add it to your path.")
    endif()
endfunction()

function(sensu_validate_objdir)
    # Ensure we're not building in-source.
    if (EXISTS ${CMAKE_BINARY_DIR}/cmake/utils.cmake)
        message(FATAL_ERROR "In-source builds are not supported. Create an objdir (inside or outside the source directory) and run CMake from there.")
    endif()
endfunction()
