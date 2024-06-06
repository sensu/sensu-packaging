##
# Sensu Agent RPMs for linux/386
##
function(build_sensu_agent_linux_386_rpm_package)
    set(PACKAGE_ARCH "i686")
    set(GOARCH "386")

    set(PACKAGECLOUD_DISTROS
        "el/6")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_rpm_settings()
    set_sensu_agent_rpm_overrides()

    build_cpack_config()
endfunction()

##
# Sensu Agent DEB for linux/386
##
function(build_sensu_agent_linux_386_deb_package)
    set(PACKAGE_ARCH "i386")
    set(GOARCH "386")

    set(PACKAGECLOUD_DISTROS
        "ubuntu/trusty"
        "ubuntu/xenial"
        "ubuntu/bionic"
        "ubuntu/focal"
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bullseye"
        "debian/bookworm"
        "debian/trixie")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
