##
# Sensu Agent RPM for linux/mips_hardfloat
##
function(build_sensu_agent_linux_mips_hardfloat_rpm_package)
    # no-op for now
endfunction()

##
# Sensu Agent DEB for linux/mips_hardfloat
##
function(build_sensu_agent_linux_mips_hardfloat_deb_package)
    set(PACKAGE_ARCH "mips")
    set(GOMIPS "hardfloat")
    set(GOARCH "mips_${GOMIPS}")

    set(PACKAGECLOUD_DISTROS
        "debian/jessie"
        "debian/stretch"
        "debian/buster"
        "debian/bookworm"
        "debian/trixie")

    set_common_settings()
    set_sensu_agent_settings()
    set_common_deb_settings()
    set_sensu_agent_deb_overrides()

    build_cpack_config()
endfunction()
