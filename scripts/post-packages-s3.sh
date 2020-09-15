#!/bin/bash

set -e
test -n "$DEBUG_BUILD_ENV" && set -x

readonly SCRIPT_DIR="$(dirname "$0")"
readonly AWS_S3_SENSU_CI_BUILDS_BUCKET="sensu-ci-builds"
readonly findCmd=${FIND_CMD:-find}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
   echo "Usage: $0 [ deliverables directory ] [ git branch ] [ git revision ]" >&2
   exit 1
fi

readonly deliverables_dir="$1"
readonly git_branch="$2"
readonly git_sha="$3"

git_branch_no_slashes="$(echo "$git_branch" | sed -e 's:/:_:g')"

build_date="$COMMIT_DATE"
if [ "x$build_date" = "x" ]; then
   build_date=$(git log -1 --format='%cd' --date=format:'%Y%m%d-%H%M' HEAD)
fi

bucket_dir="$build_date"
bucket_dir+="_$git_sha"

export AWS_ACCESS_KEY_ID="$AWS_S3_SENSU_CI_BUILDS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$AWS_S3_SENSU_CI_BUILDS_ACCESS_SECRET"

aws \
   s3 \
   cp \
   --recursive \
   --acl public-read \
   $deliverables_dir \
   s3://$AWS_S3_SENSU_CI_BUILDS_BUCKET/$git_branch_no_slashes/$bucket_dir

uploaded_build_artifacts=$(cd $deliverables_dir && $findCmd * -type f)

for file in $uploaded_build_artifacts; do
   obj="${git_branch_no_slashes}/${bucket_dir}/${file}"
   echo "Tagging $obj for artifact garbage collection..."
   aws s3api put-object-tagging --bucket $AWS_S3_SENSU_CI_BUILDS_BUCKET \
     --key "$obj" \
     --tagging '{
                  "TagSet": [
                     {
                       "Key": "garbage-collect",
                       "Value": "1"
                      }
                   ]
                }'

   sleep 1
done
