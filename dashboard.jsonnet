// dashboard.jsonnet
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

// Doc: https://grafana.github.io/grafonnet/API/dashboard/variable.html
local variables = {
  datasource:
    var.datasource.new(
      'datasource',
      'prometheus',
    )
    + var.datasource.withRegex('/Prometheus/'),

  namespace:
    var.query.new('namespace')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'namespace',
      metric='kube_pod_info',
    )
    + var.query.refresh.onLoad()
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),
};

// Dashboard
g.dashboard.new('GHA runners (test)')
+ g.dashboard.withDescription(|||
  Dashboard to monitor the resources usage and status
  of Github Actions Scale Set Runners
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
  variables.namespace,
])
+ g.dashboard.withPanels([

  // Runners row
  g.panel.row.new('Runners'),

  // Runners status
  g.panel.timeSeries.new('Runners status')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      'gha_controller_running_ephemeral_runners{exported_namespace="gha-runner"}'
    )
    + g.query.prometheus.withLegendFormat('{{name}} (running)'),
    g.query.prometheus.new(
      '${datasource}',
      'gha_controller_failed_ephemeral_runners{exported_namespace="gha-runner"}'
    )
    + g.query.prometheus.withLegendFormat('{{name}} (failed)'),
    g.query.prometheus.new(
      '${datasource}',
      'gha_controller_pending_ephemeral_runners{exported_namespace="gha-runner"}'
    )
    + g.query.prometheus.withLegendFormat('{{name}} (pending)'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(24)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(0)
  + g.panel.timeSeries.gridPos.withY(0),

  // Resources row
  g.panel.row.new('Runners resources'),

  // CPU Usage Panel
  g.panel.timeSeries.new('CPU Usage')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      'max by (container, pod) (irate(container_cpu_usage_seconds_total{namespace="gha-runner", container!=""}[5m])) / on (container, pod) kube_pod_container_resource_limits{resource="cpu", namespace="gha-runner"}'
    )
    + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(0)
  + g.panel.timeSeries.gridPos.withY(0),

  // Memory Usage Panel
  g.panel.timeSeries.new('Memory Usage')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      'max by (container, pod) (container_memory_working_set_bytes{namespace="gha-runner", container!=""}) / on (container, pod) kube_pod_container_resource_limits{resource="memory", namespace="gha-runner"}'
    )
    + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(12)
  + g.panel.timeSeries.gridPos.withY(0),

  // Nodes row
  g.panel.row.new('Nodes resources'),

  // Memory Usage Panel
  g.panel.timeSeries.new('Memory Usage')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      '100 - (node_memory_MemFree_bytes{role="gha-runner-scale-set-main"} / node_memory_MemTotal_bytes{role="gha-runner-scale-set-main"}) * 100'
    )
    + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}}'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(0)
  + g.panel.timeSeries.gridPos.withY(0),

  // Disk Usage Panel
  g.panel.timeSeries.new('Disk Usage')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      '100 - (node_filesystem_avail_bytes{device!="shm", role="gha-runner-scale-set-main"} / node_filesystem_size_bytes{device!="shm", role="gha-runner-scale-set-main"}) * 100'
    )
    + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} ({{device}})'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(12)
  + g.panel.timeSeries.gridPos.withY(0),

  // ENA Allowance Panel
  g.panel.timeSeries.new('ENA Allowance')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new(
      '${datasource}',
      'irate(node_ethtool_bw_in_allowance_exceeded{role="gha-runner-scale-set-main"}[5m])'
    )
    + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} (in)'),
    g.query.prometheus.new(
      '${datasource}',
      'irate(node_ethtool_bw_out_allowance_exceeded{role="gha-runner-scale-set-main"}[5m]) * -1'
    )
    + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} (out)'),
  ])
  + g.panel.timeSeries.standardOptions.withUnit('')
  + g.panel.timeSeries.gridPos.withW(12)
  + g.panel.timeSeries.gridPos.withH(8)
  + g.panel.timeSeries.gridPos.withX(0)
  + g.panel.timeSeries.gridPos.withY(0),
])
