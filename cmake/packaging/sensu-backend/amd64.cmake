##
# Sensu Backend RPMs for linux/amd64
##
function(build_sensu_backend_linux_amd64_rpm_package)
    set(PACKAGE_ARCH "x86_64")
    set(GOARCH "amd64")

    set(PACKAGECLOUD_DISTROS
        "el/6"
        "el/7"
        "el/8"
        "fedora/30"
        "fedora/31"
        "fedora/32"
        "fedora/33"
        "fedora/34")

    set_common_settings()
    set_sensu_backend_settings()
    set_common_rpm_settings()
    set_sensu_backend_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu Backend DEB for linux/amd64
##
function(build_sensu_backend_linux_amd64_deb_package)
    set(PACKAGE_ARCH "amd64")
    set(GOARCH "amd64")

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
    set_sensu_backend_settings()
    set_common_deb_settings()
    set_sensu_backend_deb_overrides()

    build_cpack_config()
endfunction()
