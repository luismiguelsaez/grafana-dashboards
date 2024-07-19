// dashboard.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

local vars = import './lib/variables.jsonnet';
local panels = import './lib/panels.jsonnet';
local queries = import './lib/queries.jsonnet';

// Dashboard
g.dashboard.new('GHA runners')
+ g.dashboard.withDescription(|||
  Dashboard to monitor the resources usage and status
  of Github Actions Scale Set Runners
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  vars.datasource,
  vars.namespace,
  vars.pod,
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
    panels.timeSeries.base(
      'CPU Usage',
      [
        queries.podCPUUsage,
      ],
      'percentunit'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),

    // Memory Usage Panel
    panels.timeSeries.base(
      'Memory Usage',
      [
        queries.podMemoryUsage,
      ],
      'percentunit'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),

    // CPU Throttling Panel
    panels.timeSeries.base(
      'CPU Trottling',
      [
        queries.podCPUUsage,
      ],
      'percentunit'
    )
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
    panels.timeSeries.base(
      'Memory Usage',
      [
        queries.nodeMemoryUsage,
      ],
      'percent'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),

    // CPU Usage Panel
    panels.timeSeries.base(
      'CPU Usage',
      [
        queries.nodeCPUUsage,
      ],
      'percentunit'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),

    // Disk Usage Panel
    panels.timeSeries.base(
      'Disk Usage',
      [
        queries.nodeDiskUsage,
      ],
      'percent'
    )
    // g.panel.timeSeries.new('Disk Usage')
    // + g.panel.timeSeries.queryOptions.withTargets([
    //   g.query.prometheus.new(
    //     '${datasource}',
    //     '100 - (node_filesystem_avail_bytes{device!="shm", role="gha-runner-scale-set-main"} / node_filesystem_size_bytes{device!="shm", role="gha-runner-scale-set-main"}) * 100'
    //   )
    //   + g.query.prometheus.withLegendFormat('{{kubernetes_io_hostname}} ({{device}})'),
    // ])
    // + g.panel.timeSeries.standardOptions.withUnit('percent')
    // + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(12),

    // ENA Allowance Panel
    panels.timeSeries.base(
      'ENA Allowance',
      [
        queries.nodeENABWAllowanceIN,
        queries.nodeENABWAllowanceOUT,
      ],
      'none'
    )
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
    + g.panel.table.queryOptions.transformation.withDisabled(false)
    + g.panel.table.queryOptions.transformation.withId('filterFieldsByName')
    + g.panel.table.queryOptions.transformation.withOptions({ include: { names: ['karpenter_k8s_aws_instance_cpu'] } })
    + g.panel.table.gridPos.withW(12)
    + g.panel.table.gridPos.withH(8)
    + g.panel.table.gridPos.withX(0)
    + g.panel.table.gridPos.withY(16),
  ]),
  // Dashboard End
])
