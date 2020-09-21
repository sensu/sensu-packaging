function(build_sensu_backend_packages)
    set(_app_name "sensu_backend")
    set(_pkg_type "backend")

    set(_allowed_operating_systems
        "linux")

    set(_allowed_linux_architectures
        "amd64"
        "arm64"
        "ppc64le")

    build_packages_macro()
endfunction()

# Build Sensu Backend Linux packages
function(build_sensu_backend_linux_packages)
    set(PACKAGE_OS "linux")
    set(GOOS "linux")

    foreach(_arch ${_${_os}_architectures})
        set(_component ${_app_name_dashed}-${_os}-${_arch}-pkg)
        generate_backend_manifest()

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

# Set backend settings that will be used across all backend packages (can be overridden)
function(set_sensu_backend_settings)
    setg(CPACK_PACKAGE_NAME "sensu-go-backend")
    setg(PACKAGE_DESCRIPTION "Sensu Go Backend")
    setg(PACKAGE_SUMMARY ${PACKAGE_DESCRIPTION})
    setg(PACKAGE_SHORT_NAME ${CPACK_PACKAGE_NAME})
endfunction()

# Set/Override CPACK_RPM settings for backend packages
function(set_sensu_backend_rpm_overrides)
    set(backend_rpm_hooks_path "${CMAKE_BINARY_DIR}/hooks/sensu-backend/rpm")
    setg(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "${backend_rpm_hooks_path}/before-install")
    setg(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${backend_rpm_hooks_path}/after-install")
    setg(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${backend_rpm_hooks_path}/before-remove")
    setg(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${backend_rpm_hooks_path}/after-remove")
endfunction()

# Set/Override CPACK_DEB settings for backend packages
function(set_sensu_backend_deb_overrides)
    # Create a new list for package control extras
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "")
    set(backend_deb_hooks_path "${CMAKE_BINARY_DIR}/hooks/sensu-backend/deb")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${backend_deb_hooks_path}/preinst")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${backend_deb_hooks_path}/postinst")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${backend_deb_hooks_path}/prerm")
    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${backend_deb_hooks_path}/postrm")

    # Make the package control extras list available to the parent scope
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA} PARENT_SCOPE)
endfunction()
