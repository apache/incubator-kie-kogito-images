#!/usr/bin/env bash

# Post Hook script that should be called by Kogito Service Kubernetes Pod upon initialization
# Updates the Kogito Service protobuf configMap with the monitoring files located at ${KOGITO_HOME}/data/dashboards

source $KOGITO_HOME/launch/kogito-monitoring.sh

update_monitoring_configmap