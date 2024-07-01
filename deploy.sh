#!/usr/bin/env bash

GRAFANA_URL=${1:-"https://grafana.sysdev.steercrm.dev"}
# Doc: https://grafana.com/docs/grafana/latest/developers/http_api/#service-account-token
TOKEN=${2:-""}
DASHBOARD_FILE=${3}

DASHBOARD_CODE=$(jsonnet -J vendor ${DASHBOARD_FILE})

# Doc: # Doc: https://grafana.com/docs/grafana/latest/developers/http_api/dashboard/#create--update-dashboard
curl -sL -vvv -XPOST -H"Content-type: application/json" -H"Authorization: Bearer ${TOKEN}" ${GRAFANA_URL}/api/dashboards/db --data "
{
  \"dashboard\": ${DASHBOARD_CODE}, 
  \"overwrite\": true
}"
