# Use Mozilla's dumb C-style preprocessor to preprocess files.
function(sensu_preprocess_file)
    set(_single_val_args INPUT OUTPUT)
    set(_multi_val_args DEFINE)
    # There currently aren't any of these...
    set(_options NONE)
    cmake_parse_arguments(_pp_args "${_options}" "${_single_val_args}" "${_multi_val_args}" ${ARGN})

    if (NOT EXISTS ${_pp_args_INPUT})
        message(FATAL_ERROR "Can't find preprocessor input file: ${_pp_args_INPUT}")
    endif()

    if (NOT DEFINED _pp_args_OUTPUT)
        if (_pp_args_INPUT MATCHES "\\.in$")
            string(REGEX REPLACE "\\.in$" "" _pp_args_OUTPUT ${_pp_args_INPUT})
            string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" _pp_args_OUTPUT ${_pp_args_OUTPUT})
            #set(_pp_args_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ string(REGEX REPLACE "\\.in$" "" _pp_args_OUTPUT_BASENAME ${_pp_args_INPUT_BASENAME})
        else()
            message(FATAL_ERROR "sensu_preprocess_file(): input file does not end with .in; in this case, the output file must be specified.")
        endif()
    endif()

    # We always define these
    list(APPEND _pp_defines "-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}")
    list(APPEND _pp_defines "-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}")

    foreach(_define ${_pp_args_DEFINE})
        list(APPEND _pp_defines "-D${_define}")
    endforeach()

    add_custom_command(OUTPUT ${_pp_args_OUTPUT}
        COMMAND ${CMAKE_SOURCE_DIR}/cmake/preprocessor.py -F substitution --silence-missing-directive-warnings --output ${_pp_args_OUTPUT} --marker=% ${_pp_defines} ${_pp_args_INPUT}
        DEPENDS ${_pp_args_INPUT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Pre-process ${_pp_args_INPUT} -> ${_pp_args_OUTPUT}"
        VERBATIM)

    list(APPEND _PREPROCESSED_FILES_OUTPUT ${_pp_args_OUTPUT})
    list(REMOVE_DUPLICATES _PREPROCESSED_FILES_OUTPUT)
    set(_PREPROCESSED_FILES_OUTPUT ${_PREPROCESSED_FILES_OUTPUT} CACHE INTERNAL "Preprocessor target files")
endfunction()

# This function is required to be called whenever you call 
# sensu_preprocess_file(); it sets up the final target, so the files actually
# get preprocessed.

function(sensu_finalize_preprocessed_files)
    add_custom_target(preprocessed-files
        ALL
        DEPENDS ${_PREPROCESSED_FILES_OUTPUT})
endfunction()
