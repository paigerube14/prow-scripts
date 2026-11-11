#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh
source common_run.sh
source node-scenarios/env.sh
checks

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

cp -r /home/krkn/kraken /tmp/kraken
krkn_loc=/tmp/kraken

TEMPLATE_FILE="node-scenarios/${SCENARIO_TEMPLATE_FILE##*/}"

# Substitute config with environment vars defined
envsubst < "$TEMPLATE_FILE" > /tmp/node_scenario.yaml
export SCENARIO_TYPE=node_scenarios


export SCENARIO_FILE=/tmp/node_scenario.yaml
envsubst < "$CONFIG_FILE_TEMPLATE" > /tmp/node_scenario_config.yaml

# Run Kraken
cat /tmp/node_scenario.yaml
cat /tmp/node_scenario_config.yaml
python3.11 $krkn_loc/run_kraken.py --config=/tmp/node_scenario_config.yaml -o /tmp/report.out
