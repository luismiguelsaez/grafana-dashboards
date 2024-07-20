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
+ g.dashboard.withVariables([
  vars.datasource,
  vars.namespace,
  vars.pod,
])
+ g.dashboard.withPanels(
  // Row pods resources
  [g.panel.row.new('Runners resources')]
  + utilGrid.makeGrid(
    panels=[
      panels.timeSeries.base('CPU Usage', [queries.podCPUUsage], 'percentunit'),
      panels.timeSeries.base('Memory Usage', [queries.podMemoryUsage], 'percentunit'),
      panels.timeSeries.base('CPU Trottling', [queries.podCPUThrottling], 'percentunit'),
      panels.timeSeries.base('Network Usage', [queries.podNetworkRX, queries.podNetworkTX], 'bytes'),
    ],
    panelWidth=12,
    panelHeight=8,
    startY=0
  )
  // Row nodes resources
  + [g.panel.row.new('Nodes resources')]
  + utilGrid.makeGrid(
    panels=[
      panels.timeSeries.base('CPU Usage', [queries.nodeCPUUsage], 'percentunit'),
      panels.timeSeries.base('Memory Usage', [queries.nodeMemoryUsage], 'percentunit'),
      panels.timeSeries.base('Disk Usage', [queries.nodeDiskUsage], 'percent'),
      panels.timeSeries.base('Network Usage', [queries.nodeNetworkRX, queries.nodeNetworkTX], 'bytes'),
      panels.timeSeries.base('ENA BW Allowance', [queries.nodeENABWAllowanceOUT, queries.nodeENABWAllowanceIN], 'none'),
    ],
    panelWidth=12,
    panelHeight=8,
    startY=0
  ),
)
