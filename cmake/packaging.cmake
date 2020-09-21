include(${CMAKE_SOURCE_DIR}/cmake/cpack-utils.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/package-manifest.cmake)

set_property(GLOBAL PROPERTY sensu_all_pkgs)
function(add_sensu_pkg)
    get_property(tmp GLOBAL PROPERTY sensu_all_pkgs)
    list(APPEND tmp ${ARGV})
    set_property(GLOBAL PROPERTY sensu_all_pkgs "${tmp}")
endfunction()

set_property(GLOBAL PROPERTY sensu_all_pkg_tests)
function(add_sensu_pkg_test)
    get_property(tmp GLOBAL PROPERTY sensu_all_pkg_tests)
    list(APPEND tmp ${ARGV})
    set_property(GLOBAL PROPERTY sensu_all_pkg_tests "${tmp}")
endfunction()

set_property(GLOBAL PROPERTY packagecloud_all_pkgs)
function(add_packagecloud_pkg)
    get_property(tmp GLOBAL PROPERTY packagecloud_all_pkgs)
    list(APPEND tmp ${ARGV})
    set_property(GLOBAL PROPERTY packagecloud_all_pkgs "${tmp}")
endfunction()

# Allow overriding of platforms with TARGET_PLATFORM environment variable.
# Example values: linux_arm64, linux_arm_7, etc.
macro(handle_platform_override_macro)
    if (DEFINED ENV{TARGET_PLATFORM})
        if ($ENV{TARGET_PLATFORM} MATCHES "^([^_]*)_(.*)$")
            set(_target_os ${CMAKE_MATCH_1})
            set(_target_arch ${CMAKE_MATCH_2})
        else()
            message(FATAL_ERROR "TARGET_PLATFORM is invalid")
        endif()

        set(_os_allowed (NOT ${_target_os} IN_LIST _allowed_operating_systems))
        set(_arch_allowed (NOT ${_target_arch} IN_LIST _allowed_${_target_os}_architectures))
        if ((${_os_allowed}) OR (${_arch_allowed}))
            message(STATUS "    WARNING: platform not supported for ${_app_name_dashed}: ${_target_os}/${_target_arch} (skipping...)")
        else()
            set(_operating_systems ${_target_os})
            set(_${_target_os}_architectures ${_target_arch})
        endif()
    else()
        set(_operating_systems ${_allowed_operating_systems})
        foreach(_os ${_operating_systems})
            set(_${_os}_architectures ${_allowed_${_os}_architectures})
        endforeach()
    endif()
endmacro()

macro(build_packages_macro)
    string(TOUPPER ${_app_name} _app_name_upper)
    string(REPLACE "_" "-" _app_name_dashed ${_app_name})

    message(STATUS "Generating CPack configuration for package: ${_app_name_dashed}")

    # load architecture files
    file(GLOB _arch_files
        LIST_DIRECTORIES false
        ${CMAKE_SOURCE_DIR}/cmake/packaging/${_app_name_dashed}/*.cmake)

    foreach(_arch_file ${_arch_files})
        include(${_arch_file})
    endforeach()

    handle_platform_override_macro()

    foreach(_os ${_operating_systems})
        foreach(_arch ${_${_os}_architectures})
            message(STATUS "    for platform: ${_os}_${_arch}")
        endforeach()
    endforeach()

    foreach(_os ${_operating_systems})
        call(build_${_app_name}_${_os}_packages)
    endforeach()
    unset(_operating_systems)
endmacro()

# Create a CPack package target
function(create_cpack_package_target _sensu_pkg_name _sensu_pkg_cfg)
    add_custom_command(OUTPUT ${_sensu_pkg_name}
        COMMAND ${CMAKE_CPACK_COMMAND} --config ${_sensu_pkg_cfg}
        DEPENDS ${_sensu_pkg_cfg}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM)
    add_sensu_pkg(${_sensu_pkg_name})
endfunction()

# Create a CPack publish package target
function(create_cpack_publish_package_target _pc_user _pc_repo _pc_distro _sensu_pkg_name)
    set(_pc_output "${_sensu_pkg_name}-${_pc_distro}")
    separate_arguments(_packagecloud_push_cmd UNIX_COMMAND "packagecloud push --skip-exists ${_pc_user}/${_pc_repo}/${_pc_distro} ${_sensu_pkg_name}")
    add_custom_command(OUTPUT ${_pc_output}
        COMMAND ${_packagecloud_push_cmd}
        DEPENDS ${_sensu_pkg_name}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM)
    add_packagecloud_pkg(${_pc_output})
endfunction()

# Create a CPack test package target
function(create_cpack_test_package_target _sensu_pkg_name)
    if(${PACKAGE_FILE_EXTENSION} STREQUAL "rpm")
        set(_test_snapshots_path "${CMAKE_BINARY_DIR}/tests/snapshots/${PACKAGE_SHORT_NAME}/rpm")

        # dump manifest
        set(_manifest_path "${_sensu_pkg_name}-manifest")
        separate_arguments(_dump_manifest_cmd UNIX_COMMAND "rpm -qp --dump ${_sensu_pkg_name} | awk 'BEGIN { FS=\"[ ]\" } ; { print $1,$5,$6,$7 }' > ${_manifest_path}")
        add_custom_command(OUTPUT ${_manifest_path}
            COMMAND ${_dump_manifest_cmd}
            DEPENDS ${_sensu_pkg_name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_manifest_path})

        # compare manifests (this requires `set -o pipefail` be set)
        set(_manifest_diff_path "${_manifest_path}.diff")
        separate_arguments(_compare_manifests_cmd UNIX_COMMAND "diff -u ${_test_snapshots_path}/manifest ${_manifest_path} | tee ${_manifest_diff_path}")
        add_custom_command(OUTPUT ${_manifest_diff_path}
            COMMAND ${_compare_manifests_cmd}
            DEPENDS ${_manifest_path}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_manifest_diff_path})

        # dump scripts
        set(_scripts_path "${_sensu_pkg_name}-scripts")
        separate_arguments(_dump_scripts_cmd UNIX_COMMAND "rpm -qp --scripts ${_sensu_pkg_name} > ${_scripts_path}")
        add_custom_command(OUTPUT ${_scripts_path}
            COMMAND ${_dump_scripts_cmd}
            DEPENDS ${_sensu_pkg_name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_scripts_path})

        # compare scripts (this requires `set -o pipefail` to be set)
        set(_scripts_diff_path "${_scripts_path}.diff")
        separate_arguments(_compare_scripts_cmd UNIX_COMMAND "diff -u ${_test_snapshots_path}/scripts ${_scripts_path} | tee ${_scripts_diff_path}")
        add_custom_command(OUTPUT ${_scripts_diff_path}
            COMMAND ${_compare_scripts_cmd}
            DEPENDS ${_scripts_path}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_scripts_diff_path})
    elseif(${PACKAGE_FILE_EXTENSION} STREQUAL "deb")
        set(_test_snapshots_path "${CMAKE_BINARY_DIR}/tests/snapshots/${PACKAGE_SHORT_NAME}/deb")

        # dump manifest
        set(_manifest_path "${_sensu_pkg_name}-manifest")
        separate_arguments(_dump_manifest_cmd UNIX_COMMAND "dpkg -c ${_sensu_pkg_name} > ${_manifest_path}")
        add_custom_command(OUTPUT ${_manifest_path}
            COMMAND ${_dump_manifest_cmd}
            DEPENDS ${_sensu_pkg_name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_manifest_path})

        # dump controlfiles
        set(_controlfiles_path "${_sensu_pkg_name}-controlfiles")
        separate_arguments(_dump_controlfiles_cmd UNIX_COMMAND "dpkg-deb -e ${_sensu_pkg_name} ${_controlfiles_path} && rm ${_controlfiles_path}/control ${_controlfiles_path}/md5sums")
        add_custom_command(OUTPUT ${_controlfiles_path}
            COMMAND ${_dump_controlfiles_cmd}
            DEPENDS ${_sensu_pkg_name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_controlfiles_path})

        # compare manifests (this requires `set -o pipefail` to be set)
        set(_manifest_diff_path "${_manifest_path}.diff")
        separate_arguments(_compare_manifests_cmd UNIX_COMMAND "diff -u ${_test_snapshots_path}/manifest ${_manifest_path} | tee ${_manifest_diff_path}")
        add_custom_command(OUTPUT ${_manifest_diff_path}
            COMMAND ${_compare_manifest_cmd}
            DEPENDS ${_manifest_path}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_manifest_diff_path})

        # compare controlfiles (this requires `set -o pipefail` to be set)
        set(_controlfiles_diff_path "${_controlfiles_path}.diff")
        separate_arguments(_compare_controlfiles_cmd UNIX_COMMAND "diff -u ${_test_snapshots_path}/controlfiles ${_controlfiles_path} | tee ${_controlfiles_diff_path}")
        add_custom_command(OUTPUT ${_controlfiles_diff_path}
            COMMAND ${_compare_controlfiles_cmd}
            DEPENDS ${_controlfiles_path}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM)
        add_sensu_pkg_test(${_controlfiles_diff_path})
    endif()
endfunction()

# Build CPackConfig
macro(build_cpack_config)
    string(TOLOWER ${CPACK_GENERATOR} _cpack_generator)
    set(CPACK_COMPONENTS_ALL "${_component}")
    set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};sensu-enterprise-go;${CPACK_COMPONENTS_ALL};/")
    set(CPACK_OUTPUT_CONFIG_FILE "${CMAKE_BINARY_DIR}/${PACKAGE_SHORT_NAME}-${_cpack_generator}-${PACKAGE_OS}-${PACKAGE_ARCH}-CPackConfig.cmake")
    set(_package_file "${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}")
    set(_package_output "${CMAKE_BINARY_DIR}/${_package_file}")

    include(CPack)

    # Add a target for the package
    create_cpack_package_target(${_package_output} ${CPACK_OUTPUT_CONFIG_FILE})

    # Add a target for testing the package
    create_cpack_test_package_target(${_package_output})

    # Add a target for each packagecloud distro the package should get pushed to
    set(_pc_user "sensu")
    set(_pc_repo "ci-builds")
    foreach(_pc_distro ${PACKAGECLOUD_DISTROS})
        create_cpack_publish_package_target(${_pc_user} ${_pc_repo} ${_pc_distro} ${_package_output})
    endforeach()

    # Reset the CPack state (all CPACK_ variables) or things get funky
    reset_cpack_state()
endmacro()

# Common settings used across all packages (can be overridden)
function(set_common_settings)
    setg(CPACK_PACKAGE_VERSION ${SENSU_VERSION})
    setg(CPACK_PACKAGE_CONTACT "support@sensu.io")
    setg(CPACK_PACKAGE_VENDOR "Sensu, Inc.")
    setg(CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0)
endfunction()

# Set common RPM settings used across all packages (can be overridden)
function(set_common_rpm_settings)
    setg(CPACK_GENERATOR "RPM")
    setg(CPACK_RPM_PACKAGE_AUTOREQPROV 0)
    setg(CPACK_RPM_PACKAGE_GROUP "Applications/Internet")
    setg(CPACK_RPM_PACKAGE_RELEASE ${PACKAGE_RELEASE})
    setg(CPACK_RPM_PACKAGE_DESCRIPTION ${PACKAGE_DESCRIPTION})
    setg(CPACK_RPM_PACKAGE_SUMMARY ${PACKAGE_SUMMARY})
    setg(CPACK_RPM_PACKAGE_LICENSE "Proprietary")
    setg(CPACK_RPM_PACKAGE_URL "https://sensu.io")
    setg(CPACK_RPM_PACKAGE_RELOCATABLE 0) # TODO: we may be able to make packages relocatable down the road
    setg(CPACK_RPM_COMPONENT_INSTALL 1)
    setg(CPACK_RPM_PACKAGE_ARCHITECTURE ${PACKAGE_ARCH})
    setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${PACKAGE_RELEASE}.${PACKAGE_ARCH}")
    if (DEFINED GOARM)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-armv${GOARM}")
    endif()
    if (DEFINED GOMIPS)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${GOMIPS}")
    endif()
    if (DEFINED GOMIPS64)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${GOMIPS64}")
    endif()
    setg(PACKAGE_FILE_EXTENSION "rpm")

    # Required, now that we put our daemon binaries in /usr/sbin; we also
    # don't want to conflict with packages in the distro's filesystem package
    # (which, helpfully, keep changing...)
    set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/sbin")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/var")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/var/cache")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/var/lib")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/var/log")
    list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/var/run")

    # Make CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION available to parent
    set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION ${CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION} PARENT_SCOPE)
endfunction()

# Set common DEB settings used across alll packages (can be overridden)
function(set_common_deb_settings)
    setg(CPACK_GENERATOR "DEB")
    setg(CPACK_DEBIAN_PACKAGE_SECTION "Network")
    setg(CPACK_DEBIAN_PACKAGE_RELEASE ${PACKAGE_RELEASE})
    setg(CPACK_DEBIAN_PACKAGE_DESCRIPTION "${PACKAGE_DESCRIPTION}")
    setg(CPACK_DEBIAN_PACKAGE_SUMMARY "${PACKAGE_SUMMARY}")
    setg(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://sensu.io")
    setg(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR} <${CPACK_PACKAGE_CONTACT}>")
    setg(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${PACKAGE_ARCH})
    setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}-${PACKAGE_RELEASE}_${PACKAGE_ARCH}")
    if (DEFINED GOARM)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-armv${GOARM}")
    endif()
    if (DEFINED GOMIPS)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${GOMIPS}")
    endif()
    if (DEFINED GOMIPS64)
        setg(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${GOMIPS64}")
    endif()
    setg(PACKAGE_FILE_EXTENSION "deb")
endfunction()

function(configure_sensu_packaging)
    get_property(sensu_all_pkgs GLOBAL PROPERTY sensu_all_pkgs)
    add_custom_target(sensu-packages
        DEPENDS ${sensu_all_pkgs})

    get_property(sensu_all_pkg_tests GLOBAL PROPERTY sensu_all_pkg_tests)
    add_custom_target(test-sensu-packages
        DEPENDS ${sensu_all_pkg_tests})

    get_property(packagecloud_all_pkgs GLOBAL PROPERTY packagecloud_all_pkgs)
    add_custom_target(publish-sensu-packages
        DEPENDS ${packagecloud_all_pkgs})
endfunction()

include(${CMAKE_SOURCE_DIR}/cmake/packaging/sensu-agent.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/packaging/sensu-backend.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/packaging/sensu-cli.cmake)

function(build_packages)
    build_sensu_agent_packages()
    build_sensu_backend_packages()
    build_sensu_cli_packages()
endfunction()

build_packages()
