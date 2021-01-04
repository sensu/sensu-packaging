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
Local builds are builds which are triggered by commits to this repository.
Packages produced by local builds will not be published to S3, packagecloud, or
AppVeyor but will be published as CircleCI artifacts.

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
`BRANCH` | `main` | The branch of this repository to trigger the CI build with.
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
uses the workflow id of the latest successful build for the main branch in
`sensu-enterprise-go`.

#### publish

**Type:** `boolean`
**Default:** `false`

Whether or not to publish packages to the package repository providers (S3,
packagecloud, AppVeyor).

## NuGet Feed

The AppVeyor NuGet feed that we publish Sensu NuGet packages to can be viewed at:
https://ci.appveyor.com/nuget/sensu-hjg205j7fvg1/packages. Use the AppVeyor
credentials found in 1Password when prompted.

[1]: https://github.com/sensu/sensu-enterprise-go
[2]: https://app.circleci.com/pipelines/github/sensu/sensu-enterprise-go

## Publishing CircleCI Orbs

### Development Versions

Anyone in the GitHub organization can publish development versions of orbs.
These versions will expire after 90 days and should not be used in the `main` or
`release/` branches. A dev version can be published by running the following,
specifying the orb name & dev version:

``` sh
circleci orb pack src | circleci orb publish - sensu/orb@dev:version
```

### Stable Versions

For now, CircleCI limits the publishing of CircleCI orbs to GitHub Organization
administrators. If a new release of any of our CircleCI orbs is needed, please
contact one of the GitHub Organization admins:
* [Justin][justin-slack]
* [Sean][sean-slack]
* [Cameron][cameron-slack]
* [Anthony][anthony-slack]
* [Caleb][caleb-slack]

**NOTE:** If an orb needs to be published and the GitHub Organization admins
cannot be reached via Slack, contact [Justin][justin-slack] via SMS/Phone.

Orbs can be published by checking out the latest code from the orb repository
and then running the following, specifying the orb name & dev version & whether
or not to use a major, minor, or patch level version bump:

``` sh
circleci orb pack src | circleci orb publish promote sensu/orb@dev:version bump-type
```

[justin-slack]: https://sensu.slack.com/team/U053FL3SK
[sean-slack]: https://sensu.slack.com/team/U051E44V1
[cameron-slack]: https://sensu.slack.com/team/U0562RSF2
[anthony-slack]: https://sensu.slack.com/team/U054A5JD7
[caleb-slack]: https://sensu.slack.com/team/U02L65BU5
