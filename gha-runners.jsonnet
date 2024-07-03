// dashboard.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

local vars = import './lib/variables.jsonnet';

// Dashboard
g.dashboard.new('GHA runners (test)')
+ g.dashboard.withDescription(|||
  Dashboard to monitor the resources usage and status
  of Github Actions Scale Set Runners
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  vars.datasource,
  vars.namespace,
])
+ g.dashboard.withPanels([

  // Stats row
  g.panel.row.new('Stats')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    // Listeners count
    g.panel.stat.new('Listeners count')
    + g.panel.stat.queryOptions.withTargets([
      g.query.prometheus.new('${datasource}', 'sum (gha_controller_running_listeners{exported_namespace="gha-runner"})')
      + g.query.prometheus.withLegendFormat('{{organization}}'),
    ])
    + g.panel.stat.standardOptions.withUnit('none')
    + g.panel.stat.gridPos.withW(4)
    + g.panel.stat.gridPos.withH(4)
    + g.panel.stat.gridPos.withX(0)
    + g.panel.stat.gridPos.withY(0),

    // Runners count
    g.panel.stat.new('Runners count')
    + g.panel.stat.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'sum (gha_controller_running_ephemeral_runners{exported_namespace="gha-runner"})'
      )
      + g.query.prometheus.withLegendFormat('{{organization}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('none')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(4)
    + g.panel.timeSeries.gridPos.withH(4)
    + g.panel.timeSeries.gridPos.withX(4)
    + g.panel.timeSeries.gridPos.withY(0),
  ]),

  // Runners row
  g.panel.row.new('Runners')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
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
    + g.panel.timeSeries.standardOptions.withUnit('none')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(24)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),
  ]),

  // Runners Resources row
  g.panel.row.new('Runners resources')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    // CPU Usage Panel
    g.panel.timeSeries.new('CPU Usage')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'max by (container, pod) (irate(container_cpu_usage_seconds_total{namespace="gha-runner", container!=""}[$__rate_interval])) / on (container, pod) kube_pod_container_resource_limits{resource="cpu", namespace="gha-runner"}'
      )
      + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
    ])
    // https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37
    + g.panel.timeSeries.standardOptions.withUnit('percentunit')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
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
    + g.panel.timeSeries.standardOptions.withUnit('percentunit')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),

    // CPU Throttling Panel
    g.panel.timeSeries.new('CPU Throttling')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'max by (container, pod) (irate(container_cpu_cfs_throttled_periods_total{namespace="gha-runner", container!=""}[$__rate_interval])) / on (container, pod) max by (container, pod) ((irate(container_cpu_cfs_periods_total{namespace="gha-runner", container!=""}[5m])))'
      )
      + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
    ])
    // https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37
    + g.panel.timeSeries.standardOptions.withUnit('percentunit')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(8),
  ]),

  // Nodes row
  g.panel.row.new('Nodes resources')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    // Memory Usage Panel
    g.panel.timeSeries.new('Memory Usage')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        '100 - (node_memory_MemFree_bytes{role="gha-runner-scale-set-main"} / node_memory_MemTotal_bytes{role="gha-runner-scale-set-main"}) * 100'
      )
      + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('percent')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),

    // CPU Usage Panel
    g.panel.timeSeries.new('CPU Usage')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'sum by (kubernetes_io_hostname) (irate(node_cpu_seconds_total{mode!="idle",role="gha-runner-scale-set-main"}[$__rate_interval])) / count (node_cpu_seconds_total{role="gha-runner-scale-set-main"}) by (kubernetes_io_hostname)'
      )
      + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('percent')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
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
    + g.panel.timeSeries.standardOptions.withUnit('percent')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(12),

    // ENA Allowance Panel
    g.panel.timeSeries.new('ENA Allowance')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'irate(node_ethtool_bw_in_allowance_exceeded{role="gha-runner-scale-set-main"}[$__rate_interval])'
      )
      + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} (in)'),
      g.query.prometheus.new(
        '${datasource}',
        'irate(node_ethtool_bw_out_allowance_exceeded{role="gha-runner-scale-set-main"}[$__rate_interval]) * -1'
      )
      + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} (out)'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('none')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(8),

    // Nodes Details
    g.panel.table.new('Nodes Details')
    + g.panel.table.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'node_cpu_seconds_total{karpenter_sh_registered!=""}'
      )
      + g.query.prometheus.withFormat('table')
      + g.query.prometheus.withInstant(true),
    ])
    //+ g.panel.table.queryOptions.transformation.withFilter('none')
    + g.panel.table.standardOptions.withUnit('none')
    + g.panel.table.gridPos.withW(12)
    + g.panel.table.gridPos.withH(8)
    + g.panel.table.gridPos.withX(0)
    + g.panel.table.gridPos.withY(16),
  ]),
  // Dashboard End
])
