#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG="$KRKN_KUBE_CONFIG"

# cluster version
echo "Printing cluster version"
oc version

source common_run.sh
source pod-network-filter/env.sh

KRAKEN_FOLDER="${KRAKEN_FOLDER:-/home/krkn/kraken}"
SCENARIO_TEMPLATE_PATH="pod-network-filter/${SCENARIO_TEMPLATE_FILE##*/}"
SCENARIO_PATH="$(resolve_scenario_path "$SCENARIO_FILE" "$KRAKEN_FOLDER")"
export SCENARIO_FILE="$SCENARIO_PATH"
CONFIG_FILE="/tmp/pod-network-filter-config.yaml"

envsubst < "$SCENARIO_TEMPLATE_PATH" > "$SCENARIO_PATH"
envsubst < "$CONFIG_FILE_TEMPLATE" > "$CONFIG_FILE"

checks

# Run Kraken
cat "$SCENARIO_PATH"
cat "$CONFIG_FILE"

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="pod-network-filter"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION="$(oc version -o json | jq -r '.openshiftVersion')"

python3.11 "$KRAKEN_FOLDER/run_kraken.py" --config="$CONFIG_FILE" \
  -o /tmp/report.out \
  --junit-testcase "$JUNIT_TESTCASE" \
  --junit-testcase-path "$ARTIFACT_DIR" \
  --junit-testcase-version "$TEST_VERSION"
