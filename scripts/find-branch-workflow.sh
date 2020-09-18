#!/usr/bin/env bash
set -euo pipefail

debug="${DEBUG:-0}"
circleToken="${CIRCLE_TOKEN:-}"
targetBranch="${TARGET_BRANCH:-}"

if [ "x${circleToken}" = "x" ]; then
    echo "CIRCLE_TOKEN must be set" >&2
    exit 1
fi

if [ "x${targetBranch}" = "x" ]; then
    echo "TARGET_BRANCH must be set" >&2
    exit 1
fi

apiURL="https://circleci.com/api/v2"
slug="gh/sensu/sensu-enterprise-go"
targetWorkflow=""
nextPageToken=""
page=1

while true; do
    queryParams="branch=${targetBranch}"

    if ! [ "x${nextPageToken}" = "x" ]; then
        queryParams+="&page-token=${nextPageToken}"
    fi

    if [ "${debug}" = "1" ]; then
        echo "fetching pipelines for branch: ${targetBranch}, page: ${page}"
    fi
    pipelines=$(curl -fsSL -H "Circle-Token: $circleToken" \
        $apiURL/project/$slug/pipeline?$queryParams | \
        jq -r '.')

    ((page++))

    nextPageToken=$(echo $pipelines | jq -r .next_page_token)
    items=$(echo $pipelines | jq -r '.items')

    if [ "x${items}" = "x[]" ]; then
        if [ "${nextPageToken}" = "null" ]; then
            break
        fi
        continue
    fi

    createdPipelines=$(echo $pipelines | jq -r \
        '[.items[] | select(.state == "created")]')

    if [ "x${createdPipelines}" = "[]" ]; then
        if [ "x${nextPageToken}" = "x" ]; then
            break
        fi
        continue
    fi

    pipelineIDs=$(echo $createdPipelines | jq -r '.[].id')
    for pipelineID in $pipelineIDs; do
        wNextPageToken=""
        wPage=1

        while true; do
            queryParams=""

            if ! [ "x${wNextPageToken}" = "x" ]; then
                queryParams+="page-token=${wNextPageToken}"
            fi

            if [ "${debug}" = "1" ]; then
                echo "fetching workflows for pipeline: ${pipelineID}, page: ${wPage}"
            fi
            workflows=$(curl -fsSL -H "Circle-Token: $circleToken" \
                $apiURL/pipeline/$pipelineID/workflow?wQueryParams)

            ((wPage++))

            wNextPageToken=$(echo $workflows | jq -r .next_page_token)
            buildWorkflows=$(echo $workflows | jq -r \
                '[.items[] | select(.name == "build") |
                    select(.status == "success")]')

            if [ "${buildWorkflows}" = "[]" ]; then
                if [ "${wNextPageToken}" = "null" ]; then
                    break
                fi
                continue
            fi

            targetWorkflow=$(echo $buildWorkflows | jq -r '.[0].id')
            break
        done

        if ! [ "x${targetWorkflow}" = "x" ]; then
            break
        fi
    done

    break
done

if [ "x${targetWorkflow}" = "x" ]; then
    echo "no workflow was found for branch: ${targetBranch}" >&2
    exit 1
fi

if [ "${debug}" = "1" ]; then
    echo "found workflow: ${targetWorkflow} for branch: ${targetBranch}"
else
    echo $targetWorkflow
fi
