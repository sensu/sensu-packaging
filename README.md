# Sensu Packaging

This repository contains the code required to build packages (excluding Docker).

## Remotely Triggered Builds
Remotely triggered builds are builds which are triggered by another repository.

When a commit is pushed to the `sensu-enterprise-go` repository, it will
populate the [build parameters](#build-parameters) and trigger a build for the
`main` branch in this repository. Packages are then built and uploaded to:

* Amazon S3 Bucket
  * `sensu-ci-builds`
* packagecloud Repository
    * `ci-builds`
* AppVeyor NuGet Project Feed

## Local Builds
Builds triggered by commits to this repository. Packages produced by local
builds will not be published to S3, packagecloud, or AppVeyor but will be
published as CircleCI artifacts.

## Manually Triggered Builds
Builds can be triggered using the `scripts/trigger-build.sh` script for a given
CircleCI workflow ID or git branch.

Both `curl` and `jq` must be installed for this script to work.

#### Environment Variables

**Note:** If both `TARGET_WORKFLOW` and `TARGET_BRANCH` are set then
`TARGET_WORKFLOW` will take precedence.

Environment Variable | Default Value | Description
-------------------- | ------------- | -----------
`CIRCLE_TOKEN` | | Your CircleCI API Token.
`TARGET_WORKFLOW` | | The CircleCI workflow ID of the [sensu-enterprise-go][2] build to build packages for.
`TARGET_BRANCH` | | The git branch of [sensu-enterprise-go][1] to build packages for.
`BRANCH` | `master` | The branch of this repository to trigger the CI build with.
`PUBLISH` | `true` | Controls whether or not the packages will be uploaded to packagecloud, S3, and AppVeyor. Can be set to `true` or `false`.

### Trigger a build for a workflow

Simply replace `REPLACEME` with the CircleCI workflow ID of the
[sensu-enterprise-go][2]
build that you would like to package.

```sh
TARGET_WORKFLOW="REPLACEME" ./scripts/trigger-build.sh
```

### Trigger a build for a git branch

Simply replace `REPLACEME` with the git branch of the
[sensu-enterprise-go][1]
build that you would like to package.

```sh
TARGET_BRANCH="REPLACEME" ./scripts/trigger-build.sh
```

## Build Parameters

### target_workflow

**Type:** `string`
**Default:** `""`

The remote workflow id of the desired build. It is used to fetch the build
artifacts from each of the required jobs in the remote workflow.

When value is set to an empty string the `circleci-fetch-artifacts.sh` script
uses the workflow id of the latest successful build for the master branch in
`sensu-enterprise-go`.

### sensu_version

**Type:** `string`
**Default:** `6.0.0`

The version of the local or remote build. This is used to set the version number
of the package.

### build_number

**Type:** `integer`
**Default:** `<< pipeline.number >>`

The build number of the local or remote build. This is used to set the revision
number of the package.

### commit_date

**Type:** `string`
**Default:** `""`

The date of the commit for the local or remote build. This is used to help
generate the S3 path which is used to store packages & logs.

When value is set to an empty string the `post-packages-s3.sh` script uses the
output of:

```sh
git log -1 --format='%cd' --date=format:'%Y%m%d-%H%M' HEAD
```

from the local branch.

#### publish

**Type:** `boolean`
**Default:** `false`

Whether or not to publish packages to the package repository providers (S3,
packagecloud, AppVeyor).

[1]: https://github.com/sensu/sensu-enterprise-go
[2]: https://app.circleci.com/pipelines/github/sensu/sensu-enterprise-go
