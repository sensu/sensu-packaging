#
# Manifest for sensu-backend packages
#

# sensu-backend binary
function(add_backend_binary)
    set(_source ${CMAKE_SOURCE_DIR}/target/${_os}_${_arch}/sensu-backend)
    set(_destination "/usr/sbin")

    install(PROGRAMS ${_source}
        DESTINATION ${_destination}
        COMPONENT ${_component})
endfunction()

# backend common files
function(add_backend_common_files)
    install(FILES ${CMAKE_SOURCE_DIR}/files/backend.yml.example
        DESTINATION ${SENSU_BACKEND_DOC_DIR}
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        COMPONENT ${_component})

    install(FILES ${CMAKE_SOURCE_DIR}/services/sensu-backend/systemd/etc/systemd/system/sensu-backend.service
        ${CMAKE_SOURCE_DIR}/services/sensu-backend/sysvinit/etc/init.d/sensu-backend
        DESTINATION ${SENSU_BACKEND_RESOURCE_DIR}
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        COMPONENT ${_component})
endfunction()

# backend runtime directories
function(add_backend_runtime_dirs)
    set(SENSU_BACKEND_RUNTIME_DIRS
        ${SENSU_BACKEND_DATA_DIR}
        ${SENSU_LOG_DIR}
        ${SENSU_PID_DIR})

    foreach (_runtime_dir ${SENSU_BACKEND_RUNTIME_DIRS})
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

    # $SENSU_BACKEND_CACHE_DIR also needs slightly different permissions...
    install(DIRECTORY
        DESTINATION ${SENSU_BACKEND_CACHE_DIR}
        DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        COMPONENT ${_component})
endfunction()

function(setup_backend_platform)
    add_common_files()
    add_backend_binary()
    add_backend_common_files()
    add_backend_runtime_dirs()
endfunction()

function(generate_backend_manifest)
    setup_backend_platform()
endfunction()
