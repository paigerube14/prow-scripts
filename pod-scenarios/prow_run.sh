#!/bin/bash
set -ex

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source pod-scenarios/env.sh

krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < "pod-scenarios/${SCENARIO_TEMPLATE_FILE##*/}" > /tmp/pod_scenario.yaml
export SCENARIO_FILE=/tmp/pod_scenario.yaml
envsubst < "$CONFIG_FILE_TEMPLATE" > /tmp/pod_scenario_config.yaml

cat /tmp/pod_scenario_config.yaml
cat /tmp/pod_scenario.yaml

[ -z $JUNIT_TESTCASE ] && JUNIT_TESTCASE="pod-scenarios"
[ -z $ARTIFACT_DIR ] && ARTIFACT_DIR="/tmp"

TEST_VERSION=`oc version -o json | jq .openshiftVersion`

python3.11 $krkn_loc/run_kraken.py --config=/tmp/pod_scenario_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"
