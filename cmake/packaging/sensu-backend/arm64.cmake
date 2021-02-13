##
# Sensu Backend RPMs for linux/arm64
##
function(build_sensu_backend_linux_arm64_rpm_package)
    set(PACKAGE_ARCH "aarch64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "el/7"
        "el/8"
        "fedora/30"
        "fedora/31"
        "fedora/32"
        "fedora/33")

    set_common_settings()
    set_sensu_backend_settings()
    set_common_rpm_settings()
    set_sensu_backend_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu Backend DEB for linux/arm64
##
function(build_sensu_backend_linux_arm64_deb_package)
    set(PACKAGE_ARCH "arm64")
    set(GOARCH "arm64")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "debian/jessie"
        "debian/stretch"
        "debian/buster")

    set_common_settings()
    set_sensu_backend_settings()
    set_common_deb_settings()
    set_sensu_backend_deb_overrides()

    build_cpack_config()
endfunction()
