// dashboard.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

local vars = import './lib/variables.jsonnet';
local panels = import './lib/panels.jsonnet';
local queries = import './lib/queries.jsonnet';

// Dashboard
g.dashboard.new('Applications Gloo')
+ g.dashboard.withDescription(|||
  Dashboard to monitor the resources usage and status
  of Kubernetes applications behind Gloo ingress
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  vars.datasource,
  vars.namespace,
  vars.pod,
  vars.gloo_ext_cluster,
])
+ g.dashboard.withPanels([

  // Ingress Gloo Row
  g.panel.row.new('Ingress Gloo')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    // Requests Panel
    panels.timeSeries.tableLegend(
      'Requests',
      [
        queries.glooClusterRequests,
      ],
      'none'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),

    // Response Time Panel
    panels.timeSeries.base(
      'Response Time',
      [
        queries.glooClusterRT,
      ],
      'ms'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),

    // Response Time Buckets Panel
    panels.heatmap.base(
      'Response Time buckets',
      [
        queries.glooClusterRT,
      ]
    )
    + g.panel.heatmap.gridPos.withW(12)
    + g.panel.heatmap.gridPos.withH(8)
    + g.panel.heatmap.gridPos.withX(0)
    + g.panel.heatmap.gridPos.withY(8),

    // Request Timeout Panel
    panels.timeSeries.base(
      'Request Timeout',
      [
        queries.glooClusterTimeouts,
      ],
      'none'
    )
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(8),
  ]),

  // Resources Row
  g.panel.row.new('Resources')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
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
  ]),

  // Dashboard End
])
