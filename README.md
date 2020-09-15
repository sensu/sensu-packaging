# Sensu Packaging

This repository contains the code required to build packages (excluding Docker).

## Remotely Triggered Builds
Remotely triggered builds are builds which are triggered by another repository.

When a commit is pushed to the `sensu-enterprise-go` repository, it will populate the [build parameters](#build-parameters) and trigger a build for the `main` branch in this repository. Packages are then built and uploaded to:

* Amazon S3 Bucket
  * `sensu-ci-builds`
* packagecloud Repository
    * `ci-builds`
* AppVeyor NuGet Project Feed

## Local Builds
Builds triggered by commits to this repository. Packages produced by local builds will not be published to S3, packagecloud, or AppVeyor but will be published as CircleCI artifacts.

## Manually Triggered Builds
Builds can be triggered via the CircleCI API using tools such as `curl`. To trigger a build that publishes packages, replace the values in the following example and run it:

```sh
jsonParams='{"target_workflow":"",'
jsonParams+='"sensu_version":"6.0.0",'
jsonParams+='"build_number":1,'
jsonParams+='"commit_date":"20200908-1559",'
jsonParams+='"publish":true}'

curl -fL -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' \
-H "Circle-Token: ${CIRCLE_TOKEN}" \
-d $jsonData \
https://circleci.com/api/v2/project/gh/sensu/sensu-packaging/pipeline
```

## Build Parameters

### target_workflow

**Type:** `string`
**Default:** `""`

The remote workflow id of the desired build. It is used to fetch the build artifacts from each of the required jobs in the remote workflow.

When value is set to an empty string the `circleci-fetch-artifacts.sh` script uses the workflow id of the latest successful build for the master branch in `sensu-enterprise-go`.

### sensu_version

**Type:** `string`
**Default:** `6.0.0`

The version of the local or remote build. This is used to set the version number of the package.

### build_number

**Type:** `integer`
**Default:** `<< pipeline.number >>`

The build number of the local or remote build. This is used to set the revision number of the package.

### commit_date

**Type:** `string`
**Default:** `""`

The date of the commit for the local or remote build. This is used to help generate the S3 path which is used to store packages & logs.

When value is set to an empty string the `post-packages-s3.sh` script uses the output of:

```sh
git log -1 --format='%cd' --date=format:'%Y%m%d-%H%M' HEAD
```

from the local branch.

#### publish

**Type:** `boolean`
**Default:** `false`

Whether or not to publish packages to the package repository providers (S3, packagecloud, AppVeyor).
