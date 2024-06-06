##
# Sensu Agent RPM for linux/arm_6
##
function(build_sensu_agent_linux_arm_6_rpm_package)
    # no-op for now
endfunction()

##
# Sensu Agent DEB for linux/arm_6
##
function(build_sensu_agent_linux_arm_6_deb_package)
    set(PACKAGE_ARCH "armhf")
    set(GOARM "6")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "raspbian/wheezy"
        "raspbian/jessie"
        "raspbian/stretch"
        "raspbian/buster"
        "raspbian/bullseye"
        "debian/trixie")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
