##
# Sensu CLI RPMs for linux/s390x
##
function(build_sensu_cli_linux_s390x_rpm_package)
    set(PACKAGE_ARCH "s390x")
    set(GOARCH "s390x")

    set(PACKAGECLOUD_DISTROS
        "el/6"
        "el/7"
        "el/8")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_rpm_settings()
    set_sensu_cli_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu CLI DEB for linux/s390x
##
function(build_sensu_cli_linux_s390x_deb_package)
    set(PACKAGE_ARCH "s390x")
    set(GOARCH "s390x")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "debian/jessie"
        "debian/stretch"
        "debian/buster")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
