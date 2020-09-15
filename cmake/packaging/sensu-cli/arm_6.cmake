##
# Sensu CLI RPM for linux/arm_6
##
function(build_sensu_cli_linux_arm_6_rpm_package)
    # no-op for now
endfunction()

##
# Sensu CLI DEB for linux/arm_6
##
function(build_sensu_cli_linux_arm_6_deb_package)
    set(PACKAGE_ARCH "armhf")
    set(GOARM "6")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "raspbian/wheezy"
        "raspbian/jessie"
        "raspbian/stretch"
        "raspbian/buster")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
