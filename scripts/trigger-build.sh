#!/usr/bin/env bash
set -euo pipefail

circleToken="${CIRCLE_TOKEN:-}"
targetWorkflow="${TARGET_WORKFLOW:-}"
targetBranch="${TARGET_BRANCH:-}"
branch="${BRANCH:-main}"
publish="${PUBLISH:-true}"

if [ "x${circleToken}" = "x" ]; then
    echo "CIRCLE_TOKEN must be set"
    exit 1
fi

if [ "x${targetWorkflow}" = "x" ] && [ "x${targetBranch}" = "x" ]; then
    echo "either TARGET_WORKFLOW or TARGET_BRANCH must be set"
    exit 1
fi

if [ "x${targetWorkflow}" = "x" ]; then
    baseURL='https://circleci.com/api/v1.1/project/gh/sensu/sensu-enterprise-go'
    targetWorkflow=$(curl -fsSL \
        -H 'Accept: application/json' \
        -H "Circle-Token: ${circleToken}" \
        ${baseURL}/tree/${targetBranch}?filter=successful | jq -r \
        '[.[] | select(.workflows.workflow_name != "nightly")]
        [0].workflows.workflow_id')
fi

jsonBody='{"branch":"'$branch'","parameters":{'
jsonBody+='"target_workflow":"'$targetWorkflow'",'
jsonBody+='"publish":'$publish'}'
jsonBody+='}}'

curl -vL -X POST \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "Circle-Token: ${circleToken}" \
    -d $jsonBody \
    https://circleci.com/api/v2/project/gh/sensu/sensu-packaging/pipeline
