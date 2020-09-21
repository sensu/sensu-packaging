function(build_sensu_agent_packages)
    set(_app_name "sensu_agent")
    set(_pkg_type "agent")

    set(_allowed_operating_systems
        "linux")

    set(_allowed_linux_architectures
        "386"
        "amd64"
        "arm64"
        "arm_5"
        "arm_6"
        "arm_7"
        "mips_hardfloat"
        "mipsle_hardfloat"
        "mips64le_hardfloat"
        "ppc64le"
        "s390x")

    build_packages_macro()
endfunction()

# Build Sensu Agent Linux packages
function(build_sensu_agent_linux_packages)
    set(PACKAGE_OS "linux")
    set(GOOS "linux")

    foreach(_arch ${_${_os}_architectures})
        set(_component ${_app_name_dashed}-${_os}-${_arch}-pkg)
        generate_agent_manifest()

        get_cmake_property(CPACK_COMPONENTS_ALL COMPONENTS)
        if (NOT ${_component} IN_LIST CPACK_COMPONENTS_ALL)
            message(FATAL_ERROR "Component does not exist: ${_component}")
        endif()

        set(_fn_base "build_${_app_name}_${_os}_${_arch}")
        call(${_fn_base}_rpm_package)
        call(${_fn_base}_deb_package)
    endforeach()
    unset(_${os}_architectures)
endfunction()

# Set agent settings that will be used across all agent packages (can be overridden)
function(set_sensu_agent_settings)
    setg(CPACK_PACKAGE_NAME "sensu-go-agent")
    setg(PACKAGE_DESCRIPTION "Sensu Go Agent")
    setg(PACKAGE_SUMMARY ${PACKAGE_DESCRIPTION})
    setg(PACKAGE_SHORT_NAME ${CPACK_PACKAGE_NAME})
endfunction()

# Set/Override CPACK_RPM settings for agent packages
function(set_sensu_agent_rpm_overrides)
    set(agent_rpm_hooks_path "${CMAKE_BINARY_DIR}/hooks/sensu-agent/rpm")
    setg(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "${agent_rpm_hooks_path}/before-install")
    setg(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${agent_rpm_hooks_path}/after-install")
    setg(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${agent_rpm_hooks_path}/before-remove")
    setg(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${agent_rpm_hooks_path}/after-remove")
endfunction()

# Set/Override CPACK_DEB settings for agent packages
function(set_sensu_agent_deb_overrides)
    # Create a new list for package control extras
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "")
    set(agent_deb_hooks_path "${CMAKE_BINARY_DIR}/hooks/sensu-agent/deb")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${agent_deb_hooks_path}/preinst")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${agent_deb_hooks_path}/postinst")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${agent_deb_hooks_path}/prerm")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${agent_deb_hooks_path}/postrm")

    # Make the package control extras list available to the parent scope
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA} PARENT_SCOPE)
endfunction()
