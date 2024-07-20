// dashboard.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;
local utilGrid = g.util.grid;

local vars = import './lib/variables.jsonnet';
local panels = import './lib/panels.jsonnet';
local queries = import './lib/queries.jsonnet';

// Dashboard
g.dashboard.new('GHA runners grid')
+ g.dashboard.withDescription(|||
  Dashboard to monitor the resources usage and status
  of Github Actions Scale Set Runners
|||)
+ g.dashboard.graphTooltip.withSharedCrosshair()
// Set dashboard variables
+ g.dashboard.withVariables([
  vars.datasource,
  vars.namespace,
  vars.pod,
])
+ g.dashboard.withPanels(
  // Create panels grid
  utilGrid.makeGrid(
    panels=[

      g.panel.row.new('Requests'),
      panels.timeSeries.tableLegend('Requests', [queries.glooClusterRequests], 'none'),
      panels.timeSeries.base('Response Time', [queries.glooClusterRT], 'ms'),
      panels.heatmap.base('Response Time buckets', [queries.glooClusterRT], 'ms'),
      panels.timeSeries.base('Requests Timeout', [queries.glooClusterTimeouts], 'none'),

      g.panel.row.new('Resources'),
      panels.timeSeries.base('CPU Usage', [queries.podCPUUsage], 'percentunit'),
      panels.timeSeries.base('Memory Usage', [queries.podMemoryUsage], 'percentunit'),
      panels.timeSeries.base('Disk Usage', [queries.podFSRead, queries.podFSWrite], 'bytes'),
      panels.timeSeries.base('Network Usage', [queries.podNetworkRX, queries.podNetworkTX], 'bytes'),
      panels.timeSeries.base('Opened Sockets', [queries.podSockets], 'none'),

    ],
    panelWidth=12,
    panelHeight=8,
    startY=0
  )
)
