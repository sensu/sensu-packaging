##
# Sensu CLI RPMs for linux/amd64
##
function(build_sensu_cli_linux_amd64_rpm_package)
    set(PACKAGE_ARCH "x86_64")
    set(GOARCH "amd64")

    set(PACKAGECLOUD_DISTROS
        "el/6"
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
    set_sensu_cli_settings()
    set_common_rpm_settings()
    set_sensu_cli_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu CLI DEB for linux/amd64
##
function(build_sensu_cli_linux_amd64_deb_package)
    set(PACKAGE_ARCH "amd64")
    set(GOARCH "amd64")

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
        "debian/trixie")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
