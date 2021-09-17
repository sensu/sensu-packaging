##
# Sensu CLI RPMs for linux/ppc64le
##
function(build_sensu_cli_linux_ppc64le_rpm_package)
    set(PACKAGE_ARCH "ppc64le")
    set(GOARCH "ppc64le")

    set(PACKAGECLOUD_DISTROS
        "el/8")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_rpm_settings()
    set_sensu_cli_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu CLI DEB for linux/ppc64le
##
function(build_sensu_cli_linux_ppc64le_deb_package)
    set(PACKAGE_ARCH "ppc64el")
    set(GOARCH "ppc64le")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "ubuntu/hirsute"
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
