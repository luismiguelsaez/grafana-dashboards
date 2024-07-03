// dashboard.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

local vars = import './lib/variables.jsonnet';

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
    g.panel.timeSeries.new('Requests')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'sum (irate(envoy_cluster_external_upstream_rq{envoy_cluster_name=~"$gloo_ext_cluster"}[$__rate_interval])) by (envoy_cluster_name, envoy_response_code)'
      )
      + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}} ({{envoy_response_code}})'),
    ])
    // https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37
    + g.panel.timeSeries.standardOptions.withUnit('none')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0)
    + g.panel.timeSeries.options.legend.withDisplayMode('table')
    + g.panel.timeSeries.options.legend.withPlacement('right')
    + g.panel.timeSeries.options.legend.withCalcs(['max', 'mean', 'min'])
    + g.panel.timeSeries.options.legend.withSortBy(['max']),

    // Response Time Panel
    g.panel.timeSeries.new('Response Time')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'irate(envoy_cluster_external_upstream_rq_time_sum{envoy_cluster_name=~"$gloo_ext_cluster"}[$__rate_interval]) / irate(envoy_cluster_external_upstream_rq_time_count{envoy_cluster_name=~"$gloo_ext_cluster"}[$__rate_interval])'
      )
      + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('ms')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),

    // Response Time Buckets Panel
    g.panel.heatmap.new('Response Time buckets')
    + g.panel.heatmap.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'sum by (envoy_cluster_name, le) (irate(envoy_cluster_upstream_rq_time_bucket{envoy_cluster_name=~"$gloo_ext_cluster"}[$__rate_interval]))'
      )
      + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}} ({{le}})'),
    ])
    + g.panel.heatmap.standardOptions.withUnit('none')
    + g.panel.heatmap.options.withCalculate(true)
    + g.panel.heatmap.options.calculation.yBuckets.scale.withLog(2)
    + g.panel.heatmap.options.calculation.yBuckets.scale.withType('log')
    + g.panel.heatmap.gridPos.withW(12)
    + g.panel.heatmap.gridPos.withH(8)
    + g.panel.heatmap.gridPos.withX(0)
    + g.panel.heatmap.gridPos.withY(8),

    // Request Timeout Panel
    g.panel.timeSeries.new('Request Timeout')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'sum by (envoy_cluster_name) (increase(envoy_cluster_upstream_rq_timeout{envoy_cluster_name=~"$gloo_ext_cluster"}[$__rate_interval]))'
      )
      + g.query.prometheus.withLegendFormat('{{envoy_cluster_name}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('none')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(8),
  ]),

  // Resources Row
  g.panel.row.new('Resources')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    // Requests Panel
    g.panel.timeSeries.new('CPU Usage')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'max by (container, pod) (rate(container_cpu_usage_seconds_total{namespace=~"$namespace", pod=~"$pod", container!=""}[$__rate_interval])) / on (container, pod) kube_pod_container_resource_limits{resource="cpu", pod=~"$pod", namespace=~"$namespace", container!=""}'
      )
      + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
    ])
    // https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37
    + g.panel.timeSeries.standardOptions.withUnit('percentunit')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(0)
    + g.panel.timeSeries.gridPos.withY(0),

    // Memory Usage Panel
    g.panel.timeSeries.new('Memory Usage')
    + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '${datasource}',
        'max by (container, pod) (container_memory_usage_bytes{namespace=~"$namespace", pod=~"$pod", container!=""}) / on (container, pod) kube_pod_container_resource_limits{resource="memory", namespace=~"$namespace", pod=~"$pod", container!=""}'
      )
      + g.query.prometheus.withLegendFormat('{{container}} @ {{pod}}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('percentunit')
    + g.panel.timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth')
    + g.panel.timeSeries.gridPos.withW(12)
    + g.panel.timeSeries.gridPos.withH(8)
    + g.panel.timeSeries.gridPos.withX(12)
    + g.panel.timeSeries.gridPos.withY(0),
  ]),

  // Dashboard End
])