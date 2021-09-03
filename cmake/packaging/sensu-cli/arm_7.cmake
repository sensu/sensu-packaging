##
# Sensu CLI RPM for linux/arm_7
##
function(build_sensu_cli_linux_arm_7_rpm_package)
    set(PACKAGE_ARCH "armv7hl")
    set(GOARM "7")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "fedora/30"
        "fedora/31"
        "fedora/32"
        "fedora/33"
        "fedora/34")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_rpm_settings()
    set_sensu_cli_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu CLI DEB for linux/arm_7
##
function(build_sensu_cli_linux_arm_7_deb_package)
    set(PACKAGE_ARCH "armhf")
    set(GOARM "7")
    set(GOARCH "arm_${GOARM}")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "ubuntu/hirsute"
        "debian/jessie"
        "debian/stretch"
        "debian/buster")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
