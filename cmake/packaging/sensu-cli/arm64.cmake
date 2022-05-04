##
# Sensu CLI RPM for linux/arm64
##
function(build_sensu_cli_linux_arm64_rpm_package)
    set(PACKAGE_ARCH "aarch64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "el/7"
        "el/8"
        "fedora/30"
        "fedora/31"
        "fedora/32"
        "fedora/33"
        "fedora/34"
        "fedora/35")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_rpm_settings()
    set_sensu_cli_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu CLI DEB for linux/arm64
##
function(build_sensu_cli_linux_arm64_deb_package)
    set(PACKAGE_ARCH "arm64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "ubuntu/jammy"
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bullseye")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
