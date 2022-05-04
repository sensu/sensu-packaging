##
# Sensu Agent RPMs for linux/ppc64le
##
function(build_sensu_agent_linux_ppc64le_rpm_package)
    set(PACKAGE_ARCH "ppc64le")
    set(GOARCH "ppc64le")

    set(PACKAGECLOUD_DISTROS
        "el/8"
        "fedora/35")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_rpm_settings()
    set_sensu_agent_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu Agent DEB for linux/ppc64le
##
function(build_sensu_agent_linux_ppc64le_deb_package)
    set(PACKAGE_ARCH "ppc64el")
    set(GOARCH "ppc64le")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "ubuntu/hirsute"
        "ubuntu/jammy"
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bullseye")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
