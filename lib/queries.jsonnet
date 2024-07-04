// panels.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local variables = import './variables.jsonnet';
local prometheusQuery = g.query.prometheus;

{
  glooClusterRT:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (envoy_cluster_name, le) (
          irate(
            envoy_cluster_upstream_rq_time_bucket{
              envoy_cluster_name=~"$gloo_ext_cluster"
            }
            [$__rate_interval]
          )
        )
      |||
    ),
}