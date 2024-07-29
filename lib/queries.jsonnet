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

  podCPUThrottling:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          container_cpu_cfs_throttled_periods_total{
            namespace=~"$%s",
            pod=~"$%s",
            container!=""
          }
          [$__rate_interval]
        ) / on (container, pod)
        irate(
          container_cpu_cfs_periods_total{
            namespace=~"$%s",
            pod=~"$%s",
            container!=""
          }
          [$__rate_interval]
        )
      ||| % [variables.namespace.name, variables.pod.name, variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{container}} @ {{pod}}'),

  podMemoryUsageAbs:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        max by (container, pod) (
          container_memory_usage_bytes{
              namespace=~"$%s",
              pod=~"$%s",
              container!=""
          }
        )
      ||| % [variables.namespace.name, variables.pod.name]
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

  podSockets:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (pod) (
            (
              container_sockets{
                namespace=~"$%s",
                pod=~"$%s"
              }
            )
        )
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{pod}}'),

  podOOMKills:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(
          sum_over_time(
            container_oom_events_total{
              namespace=~"$%s",
              pod=~"$%s"
            }
            [8h]
          )
        )
      ||| % [variables.namespace.name, variables.pod.name]
    )
    + prometheusQuery.withLegendFormat('{{pod}} @ {{container}}'),

  // Kubernetes nodes
  nodeCPUUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (kubernetes_io_hostname) (
          irate(
            node_cpu_seconds_total{
              mode!="idle",
              role=~"$%s"
            }
            [$__rate_interval]
          )
        )
        /
        count by (kubernetes_io_hostname) (
          node_cpu_seconds_total{
            role=~"$%s"
          }
        )
      ||| % [variables.node_role.name, variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} - {{role}}'),

  nodeMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        node_memory_MemFree_bytes{
          role=~"$%s"
        }
        /
        node_memory_MemTotal_bytes{
          role=~"$%s"
        }
      ||| % [variables.node_role.name, variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} - {{role}}'),

  nodeDiskUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        node_filesystem_avail_bytes{
          device!="shm",
          role=~"$%s"
        }
        /
        node_filesystem_size_bytes{
          device!="shm",
          role=~"$%s"
        }
      ||| % [variables.node_role.name, variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} ({{device}}) - {{role}}'),

  nodeENABWAllowanceIN:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_ethtool_bw_in_allowance_exceeded{
            role=~"$%s"
          }
          [$__rate_interval]
        )
      ||| % [variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (in) - {{role}}'),

  nodeENABWAllowanceOUT:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_ethtool_bw_out_allowance_exceeded{
            role=~"$%s"
          }
          [$__rate_interval]
        ) * -1
      ||| % [variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (out) - {{role}}'),

  nodeNetworkRX:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_network_receive_bytes_total{
            role=~"$%s"
          }
          [$__rate_interval]
        )
      ||| % [variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (RX) - {{role}}'),

  nodeNetworkTX:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        irate(
          node_network_transmit_bytes_total{
            role=~"$%s"
          }
          [$__rate_interval]
        ) * -1
      ||| % [variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} (TX) - {{role}}'),

  nodeOOMKills:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(
          sum_over_time(
            node_vmstat_oom_kill{
              role=~"$%s"
            }
            [8h]
          )
        )
      ||| % [variables.node_role.name]
    )
    + prometheusQuery.withLegendFormat('{{kubernetes_io_hostname}} - {{role}}'),

  // GHA Runners
  ghaRunnerListenerCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum (gha_controller_running_listeners)
      |||
    ),

  ghaRunnerRunningCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum (gha_controller_running_ephemeral_runners) by (name)
      |||
    )
    + prometheusQuery.withLegendFormat('{{name}} - running'),

  ghaRunnerPendingCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum (gha_controller_pending_ephemeral_runners) by (name)
      |||
    )
    + prometheusQuery.withLegendFormat('{{name}} - pending'),

  ghaRunnerFailedCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum (gha_controller_failed_ephemeral_runners) by (name)
      |||
    )
    + prometheusQuery.withLegendFormat('{{name}} - failed'),
}
