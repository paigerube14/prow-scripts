#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh
source common_run.sh
source zone-outages/env.sh
checks

export KUBECONFIG=$KRKN_KUBE_CONFIG

krn_loc=/home/krkn/kraken

# cluster version
echo "Printing cluster version"
oc version

export SCENARIO_FILE=/tmp/zone_outage.yaml

# Substitute config with environment vars defined
envsubst < "zone-outages/${SCENARIO_TEMPLATE_FILE##*/}" > $SCENARIO_FILE


envsubst < "$CONFIG_FILE_TEMPLATE" > /tmp/zone_config.yaml

# Run Kraken
cat /tmp/zone_outage.yaml
cat /tmp/zone_config.yaml
python3.11 $krn_loc/run_kraken.py --config=/tmp/zone_config.yaml -o /tmp/report.out
