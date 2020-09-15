# Add common files for a given package type, os, and arch
function(add_common_files)
    set(_readme files/README.${_pkg_type})
    set(_destination "/usr/share/doc/sensu-go-${_pkg_type}-${SENSU_VERSION}/")

    # Install package-specific README
    configure_file(${CMAKE_SOURCE_DIR}/${_readme}
        ${CMAKE_BINARY_DIR}/${_readme}
        @ONLY
        NEWLINE_STYLE UNIX)

    install(FILES ${CMAKE_BINARY_DIR}/${_readme}
        DESTINATION ${_destination}
        PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
        RENAME README.txt
        COMPONENT ${_component})

    # Install standard license
    install(FILES ${CMAKE_SOURCE_DIR}/files/LICENSE.txt
        DESTINATION ${_destination}
        PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
        COMPONENT ${_component})
endfunction()

include(${CMAKE_SOURCE_DIR}/cmake/manifests/sensu-agent.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/manifests/sensu-backend.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/manifests/sensu-cli.cmake)
