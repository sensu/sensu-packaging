include(${CMAKE_SOURCE_DIR}/cmake/preprocessor.cmake)

# Various runtime directories; some of these are shared across the agent and
# the backend.
# Note: these are hard-coded paths and will need to vary based on what platform(s)
# are being targeted.
set(SENSU_CONFIG_DIR /etc/sensu)
set(SENSU_CACHE_DIR_ROOT /var/cache/sensu)
set(SENSU_DATA_DIR_ROOT /var/lib/sensu)
set(SENSU_LOG_DIR /var/log/sensu)
set(SENSU_PID_DIR /var/run/sensu)

# Note: this is based on on the above directory paths, and is hardcoded here
# because the paths need to be used in other parts of the packaging; however,
# this hardcoding is brittle and should be revisited at some point.
set(SENSU_AGENT_DOC_DIR /usr/share/doc/sensu-go-agent-${SENSU_VERSION})
set(SENSU_BACKEND_DOC_DIR /usr/share/doc/sensu-go-backend-${SENSU_VERSION})

# Note: The resource directory is for files that are needed to exist on disk for correct
# packaging pre/post install script operation.
# Files used in packaging scripts should not be installed in the docs directory.
# Package managers provide user options to exclude docs to save disk space.
# Common pattern to exclude docs in container images.
set(SENSU_AGENT_RESOURCE_DIR /usr/share/sensu-go-agent-${SENSU_VERSION})
set(SENSU_BACKEND_RESOURCE_DIR /usr/share/sensu-go-backend-${SENSU_VERSION})

set(SENSU_AGENT_CACHE_DIR ${SENSU_CACHE_DIR_ROOT}/sensu-agent)
set(SENSU_AGENT_DATA_DIR ${SENSU_DATA_DIR_ROOT}/sensu-agent)
set(SENSU_BACKEND_CACHE_DIR ${SENSU_CACHE_DIR_ROOT}/sensu-backend)
set(SENSU_BACKEND_DATA_DIR ${SENSU_DATA_DIR_ROOT}/sensu-backend)

include(${CMAKE_SOURCE_DIR}/cmake/packaging.cmake)

configure_sensu_packaging()

set(SENSU_PACKAGING_PP_FILES
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/rpm/after-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/rpm/after-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/rpm/before-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/rpm/before-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/deb/postinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/deb/postrm.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/deb/preinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-agent/deb/prerm.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/rpm/after-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/rpm/after-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/rpm/before-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/rpm/before-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/deb/postinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/deb/postrm.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/deb/preinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-backend/deb/prerm.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/rpm/after-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/rpm/after-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/rpm/before-install.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/rpm/before-remove.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/deb/postinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/deb/postrm.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/deb/preinst.in
    ${CMAKE_SOURCE_DIR}/hooks/sensu-cli/deb/prerm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/deb/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/deb/controlfiles/postinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/deb/controlfiles/postrm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/deb/controlfiles/preinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/deb/controlfiles/prerm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/rpm/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-agent/rpm/scripts.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/deb/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/deb/controlfiles/postinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/deb/controlfiles/postrm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/deb/controlfiles/preinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/deb/controlfiles/prerm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/rpm/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-backend/rpm/scripts.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/deb/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/deb/controlfiles/postinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/deb/controlfiles/postrm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/deb/controlfiles/preinst.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/deb/controlfiles/prerm.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/rpm/manifest.in
    ${CMAKE_SOURCE_DIR}/tests/snapshots/sensu-go-cli/rpm/scripts.in)

# Extra things we need to define for preprocessing the packaging scripts
#
# Admittedly, this is kinda janky: SENSU_PACKAGING_PP_DEFINES defines the
# values of things that need to be defined, and then ALL_PP_DEFINES puts it
# in the argument format sensu_preprocess_file() is expecting.
set(SENSU_PACKAGING_PP_DEFINES
    HOOKS_DIR=${CMAKE_SOURCE_DIR}/hooks
    SENSU_VERSION=${SENSU_VERSION}
    SENSU_CACHE_DIR=${SENSU_CACHE_DIR}
    SENSU_CONFIG_DIR=${SENSU_CONFIG_DIR}
    SENSU_LOG_DIR=${SENSU_LOG_DIR}
    SENSU_PID_DIR=${SENSU_PID_DIR}
    SENSU_AGENT_CACHE_DIR=${SENSU_AGENT_CACHE_DIR}
    SENSU_AGENT_DATA_DIR=${SENSU_AGENT_DATA_DIR}
    SENSU_BACKEND_CACHE_DIR=${SENSU_BACKEND_CACHE_DIR}
    SENSU_BACKEND_DATA_DIR=${SENSU_BACKEND_DATA_DIR}
    SENSU_AGENT_DOC_DIR=${SENSU_AGENT_DOC_DIR}
    SENSU_BACKEND_DOC_DIR=${SENSU_BACKEND_DOC_DIR}
    SENSU_AGENT_RESOURCE_DIR=${SENSU_AGENT_RESOURCE_DIR}
    SENSU_BACKEND_RESOURCE_DIR=${SENSU_BACKEND_RESOURCE_DIR})

foreach(_pp_def ${SENSU_PACKAGING_PP_DEFINES})
    list(APPEND ALL_PP_DEFINES DEFINE ${_pp_def})
endforeach()

foreach(_pp_file ${SENSU_PACKAGING_PP_FILES})
    sensu_preprocess_file(INPUT ${_pp_file} ${ALL_PP_DEFINES})
endforeach()

sensu_finalize_preprocessed_files()
