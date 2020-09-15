#
# Manifest for sensu-agent packages
#

# sensu-agent binary
function(add_agent_binary)
    set(_source ${CMAKE_SOURCE_DIR}/target/${_os}_${_arch}/sensu-agent)
    set(_destination "/usr/sbin")

    install(PROGRAMS ${_source}
        DESTINATION ${_destination}
        COMPONENT ${_component})
endfunction()

# agent common files
function(add_agent_common_files)
    install(FILES ${CMAKE_SOURCE_DIR}/files/agent.yml.example
        DESTINATION ${SENSU_AGENT_DOC_DIR}
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        COMPONENT ${_component})

    install(FILES ${CMAKE_SOURCE_DIR}/services/sensu-agent/systemd/etc/systemd/system/sensu-agent.service
        ${CMAKE_SOURCE_DIR}/services/sensu-agent/sysvinit/etc/init.d/sensu-agent
        DESTINATION ${SENSU_AGENT_RESOURCE_DIR}
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        COMPONENT ${_component})
endfunction()

# agent runtime directories
function(add_agent_runtime_dirs)
    set(SENSU_AGENT_RUNTIME_DIRS
        ${SENSU_AGENT_CACHE_DIR}
        ${SENSU_AGENT_DATA_DIR}
        ${SENSU_LOG_DIR}
        ${SENSU_PID_DIR})

    foreach (_runtime_dir ${SENSU_AGENT_RUNTIME_DIRS})
        install(DIRECTORY
            DESTINATION ${_runtime_dir}
            DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE
            COMPONENT ${_component})
    endforeach()

    # /etc/sensu needs slightly different permissions...
    install(DIRECTORY
        DESTINATION ${SENSU_CONFIG_DIR}
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        COMPONENT ${_component})
endfunction()

function(setup_agent_platform)
    add_common_files()
    add_agent_binary()
    add_agent_common_files()
    add_agent_runtime_dirs()
endfunction()

function(generate_agent_manifest)
    setup_agent_platform()
endfunction()
