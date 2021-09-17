##
# Sensu Agent RPM for linux/arm_5
##
function(build_sensu_agent_linux_arm_5_rpm_package)
    # no-op for now
endfunction()

##
# Sensu Agent DEB for linux/arm_5
##
function(build_sensu_agent_linux_arm_5_deb_package)
    set(PACKAGE_ARCH "armel")
    set(GOARM "5")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bullseye")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
