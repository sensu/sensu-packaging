# Updating test data

## Update manifests

From this directory:

1. `dpkg -c path-to-example-backend.deb | awk 'BEGIN { FS=" *" } ; { print $1,$2,$6 }' > manifest.in`.
2. Replace any instances of versions with `@SENSU_VERSION@`.

## Update scripts

From this directory:

1. `dpkg-deb -e path-to-example-backend.deb controlfiles`.
2. `rm controlfiles/control controlfiles/md5sums`.
3. `find ./controlfiles -type f -exec mv '{}' '{}'.in \;`.
4. Replace any instances of versions in all files within the controlfiles directory 
   with `@SENSU_VERSION`:
   `sed -i'.bak' -e 's/5\.2\.1/@SENSU_VERSION@/' controlfiles/*.in && rm controlfiles/*.bak`.
