##
# Sensu Agent RPM for linux/arm64
##
function(build_sensu_agent_linux_arm64_rpm_package)
    set(PACKAGE_ARCH "aarch64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "el/7"
        "el/8"
        "el/9"
        "fedora/30"
        "fedora/31"
        "fedora/32"
        "fedora/33"
        "fedora/34"
        "fedora/35"
        "fedora/36"
        "fedora/37"
        "fedora/38"
        "fedora/39"
        "fedora/40")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_rpm_settings()
    set_sensu_agent_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu Agent DEB for linux/arm64
##
function(build_sensu_agent_linux_arm64_deb_package)
    set(PACKAGE_ARCH "arm64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "ubuntu/hirsute"
        "ubuntu/jammy"
        "ubuntu/noble"
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bullseye"
        "debian/bookworm"
        "raspbian/bullseye"
        "debian/trixie")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
