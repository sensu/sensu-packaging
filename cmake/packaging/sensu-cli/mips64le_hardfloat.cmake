##
# Sensu CLI RPM for linux/mips64le_hardfloat
##
function(build_sensu_cli_linux_mips64le_hardfloat_rpm_package)
    # no-op for now
endfunction()

##
# Sensu CLI DEB for linux/mips64le_hardfloat
##
function(build_sensu_cli_linux_mips64le_hardfloat_deb_package)
    set(PACKAGE_ARCH "mips64el")
    set(GOMIPS64 "hardfloat")
    set(GOARCH "mips64le_${GOMIPS64}")

    set(PACKAGECLOUD_DISTROS
        "debian/stretch"
        "debian/buster"
        "debian/bullseye"
        "debian/bookworm")

    set_common_settings()
    set_sensu_cli_settings()
    set_common_deb_settings()
    set_sensu_cli_deb_overrides()

    build_cpack_config()
endfunction()
