#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG="$KRKN_KUBE_CONFIG"
KRAKEN_FOLDER="${KRAKEN_FOLDER:-/home/krkn/kraken}"

# cluster version
echo "Printing cluster version"
oc version

source node-io-hog/env.sh
source common_run.sh

SCENARIO_TEMPLATE_PATH="node-io-hog/${SCENARIO_TEMPLATE_FILE##*/}"
SCENARIO_PATH="$(resolve_scenario_path "$SCENARIO_FILE" "$KRAKEN_FOLDER")"
export SCENARIO_FILE="$SCENARIO_PATH"
CONFIG_FILE="$KRAKEN_FOLDER/io_hog_config.yaml"

envsubst < "$SCENARIO_TEMPLATE_PATH" > "$SCENARIO_PATH"

# Substitute config with environment vars defined
envsubst < "$CONFIG_FILE_TEMPLATE" > "$CONFIG_FILE"

checks

# Run Kraken

cd "$KRAKEN_FOLDER"
cat "$CONFIG_FILE"
cat "$SCENARIO_FILE"

python3.11 run_kraken.py --config="$CONFIG_FILE" -o /tmp/report.out

