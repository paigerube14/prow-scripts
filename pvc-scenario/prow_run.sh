#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version


source pvc-scenario/env.sh

krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < "pvc-scenario/${SCENARIO_TEMPLATE_FILE##*/}" > /tmp/pvc_scenario.yaml
export SCENARIO_FILE="/tmp/pvc_scenario.yaml"
envsubst < "$CONFIG_FILE_TEMPLATE" > /tmp/pvc_scenario_config.yaml

# Run Kraken
cat /tmp/pvc_scenario_config.yaml
cat /tmp/pvc_scenario.yaml
python3.11 $krkn_loc/run_kraken.py --config=/tmp/pvc_scenario_config.yaml -o /tmp/report.out 2>&1

