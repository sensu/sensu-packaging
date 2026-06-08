#!/bin/bash
set -o pipefail

# Wrapper around packagecloud push that treats "already been taken" as success.
# Packagecloud normalizes filenames (e.g. strips -armv7 suffix from .deb),
# so --skip-exists doesn't always catch duplicates.

DISTRO="$1"
PACKAGE="$2"

output=$(packagecloud push --skip-exists "$DISTRO" "$PACKAGE" 2>&1)
rc=$?

echo "$output"

if [ $rc -ne 0 ]; then
    if echo "$output" | grep -q "already been taken"; then
        echo "Package already exists (filename normalized by packagecloud), skipping."
        exit 0
    fi
    exit $rc
fi
