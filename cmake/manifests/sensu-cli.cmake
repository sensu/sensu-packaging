#
# Manifest for sensu-cli packages
#

# sensuctl binary
function(add_ctl_binary)
    set(_source ${CMAKE_SOURCE_DIR}/target/${_os}_${_arch}/sensuctl)
    set(_destination "/usr/bin")

    install(PROGRAMS ${_source}
        DESTINATION ${_destination}
        COMPONENT ${_component})
endfunction()

function(setup_cli_platform)
    add_common_files()
    add_ctl_binary()
endfunction()

function(generate_cli_manifest)
    setup_cli_platform()
endfunction()
