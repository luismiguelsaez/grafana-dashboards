// panels.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local variables = import './variables.jsonnet';
local prometheusQuery = g.query.prometheus;

{
  glooClusterRT:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (envoy_cluster_name) (
          irate(
            envoy_cluster_upstream_rq_time_sum{
              envoy_cluster_name=~"$%s"
            }
            [$__rate_interval]
          )
          /
          irate(
            envoy_cluster_upstream_rq_time_count{
              envoy_cluster_name=~"$%s"
            }
            [$__rate_interval]
          )
        )
      ||| % [variables.gloo_ext_cluster.name, variables.gloo_ext_cluster.name]
    )
    + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}}'),

  glooClusterRTBuckets:
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
    )
    + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}} {{le}}'),

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

  podFSWrite:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod,container) (
          irate(
            (
              container_fs_writes_bytes_total{
                namespace=~"$%s",
                pod=~"$%s",
                container!=""
              }
              [$__rate_interval]
            )
          )
        ) * -1
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}} (Write)'),

  podFSRead:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod, container) (
          irate(
            (
              container_fs_reads_bytes_total{
                namespace=~"$%s",
                pod=~"$%s",
                container!=""
              }
              [$__rate_interval]
            )
          )
        )
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}} (Read)'),

  podBlkIOWrite:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod, container, operation) (
          irate(
            (
              container_blkio_device_usage_total{
                namespace=~"$%s",
                pod=~"$%s",
                container!="",
                operation=~"Write"
              }
              [$__rate_interval]
            )
          )
        ) * -1
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}} (Write)'),

  podBlkIORead:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod, container, operation) (
          irate(
            (
              container_blkio_device_usage_total{
                namespace=~"$%s",
                pod=~"$%s",
                container!="",
                operation=~"Read"
              }
              [$__rate_interval]
            )
          )
        )
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{pod}} @ {{container}} (Read)'),

  podNetworkRX:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod) (
          irate(
            (
              container_network_receive_bytes_total{
                namespace=~"$%s",
                pod=~"$%s"
              }
              [$__rate_interval]
            )
          )
        )
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{pod}} (RX)'),

  podNetworkTX:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod) (
          irate(
            (
              container_network_transmit_bytes_total{
                namespace=~"$%s",
                pod=~"$%s"
              }
              [$__rate_interval]
            )
          )
        ) * -1
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{pod}} (TX)'),

  nodeCPUUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (kubernetes_io_hostname) (
          irate(
            node_cpu_seconds_total{
              mode!="idle",
              role="gha-runner-scale-set-main"
            }
            [$__rate_interval]
          )
        )
        /
        count by (kubernetes_io_hostname) (
          node_cpu_seconds_total{
            role="gha-runner-scale-set-main"
          }
        )
      |||
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} ({{device}})'),

  nodeMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        100 - (
          node_memory_MemFree_bytes{
            role="gha-runner-scale-set-main"
          }
          /
          node_memory_MemTotal_bytes{
            role="gha-runner-scale-set-main"
          }
        ) * 100
      |||
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} ({{device}})'),

  nodeDiskUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        100 - (
          node_filesystem_avail_bytes{
            device!="shm",
            role="gha-runner-scale-set-main"
          }
          /
          node_filesystem_size_bytes{
            device!="shm",
            role="gha-runner-scale-set-main"
          }
        ) * 100
      |||
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} ({{device}})'),

  nodeENABWAllowanceIN:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_ethtool_bw_in_allowance_exceeded{
            role="gha-runner-scale-set-main"
          }
          [$__rate_interval]
        )
      |||
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (in)'),

  nodeENABWAllowanceOUT:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_ethtool_bw_out_allowance_exceeded{
            role="gha-runner-scale-set-main"
          }
          [$__rate_interval]
        ) * -1
      |||
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (out)'),
}