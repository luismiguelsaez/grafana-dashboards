#!/usr/bin/env bash

# Doc: https://grafana.com/docs/grafana/latest/developers/http_api/#service-account-token
TOKEN=${1:-""}

DASHBOARD_CODE=$(jsonnet -J vendor dashboard.jsonnet)

# Doc: # Doc: https://grafana.com/docs/grafana/latest/developers/http_api/dashboard/#create--update-dashboard
curl -sL -vvv -XPOST -H"Content-type: application/json" -H"Authorization: Bearer $TOKEN" https://grafana.sysdev.steercrm.dev/api/dashboards/db --data "
{
  \"dashboard\": ${DASHBOARD_CODE}, 
  \"overwrite\": true
}"
