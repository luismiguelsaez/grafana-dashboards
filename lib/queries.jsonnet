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
              envoy_cluster_name=~"$%s"
            }
            [$__rate_interval]
          )
        )
      ||| % [variables.gloo_ext_cluster.name]
    ),

  podCPUUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        max by (container, pod) (
          rate(
            container_cpu_usage_seconds_total{
              namespace=~"$%s",
              pod=~"$%s",
              container!=""
            }
            [$__rate_interval])
          ) / on (container, pod)
          kube_pod_container_resource_limits{
            resource="cpu",
            namespace=~"$%s",
            pod=~"$%s",
            container!=""
          }
      ||| % [variables.namespace.name, variables.pod.name, variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}}'),
}
