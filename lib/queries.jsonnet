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

  glooClusterTimeouts:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (envoy_cluster_name) (
          increase(
            envoy_cluster_upstream_rq_timeout{
              envoy_cluster_name=~"$%s"
            }
            [$__rate_interval]
          )
        )
      ||| % [variables.gloo_ext_cluster.name]
    )
    + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}}'),

  glooClusterRequests:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (envoy_cluster_name, envoy_response_code) (
          irate(
            envoy_cluster_external_upstream_rq{
              envoy_cluster_name=~"$%s"
            }
            [$__rate_interval]
          )
        )
      ||| % [variables.gloo_ext_cluster.name]
    )
    + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}}'),

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

  podMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        max by (container, pod) (
          container_memory_usage_bytes{
              namespace=~"$%s",
              pod=~"$%s",
              container!=""
          }
        ) / on (container, pod)
        kube_pod_container_resource_limits{
          resource="memory",
          namespace=~"$%s",
          pod=~"$%s",
          container!=""
        }
      ||| % [variables.namespace.name, variables.pod.name, variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}}'),
}