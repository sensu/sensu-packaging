# Updating test data

## Update manifests

From this directory:

1. `rpm -qp --dump path-to-example-cli.rpm | awk 'BEGIN { FS="[ ]" } ; { print $1,$5,$6,$7 }' > manifest.in`.
2. Replace any instances of versions with `@SENSU_VERSION@`.

## Update scripts

From this directory:

1. `rpm -qp --scripts path-to-example-cli.rpm > scripts.in`.
2. Replace any instances of versions with `@SENSU_VERSION`.
