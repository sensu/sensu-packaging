##
# Sensu Agent RPM for linux/arm_7
##
function(build_sensu_agent_linux_arm_7_rpm_package)
    # no-op for now
endfunction()

##
# Sensu Agent DEB for linux/arm_7
##
function(build_sensu_agent_linux_arm_7_deb_package)
    set(PACKAGE_ARCH "armhf")
    set(GOARM "7")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "debian/jessie"
        "debian/stretch"
        "debian/buster")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
