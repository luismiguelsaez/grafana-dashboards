// panels.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

// Documentation
// Units: https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37

{
  heatmap: {
    local heatmap = g.panel.heatmap,
    local options = heatmap.options,

    base(title, targets):
      heatmap.new(title)
      + heatmap.queryOptions.withTargets(targets)
      + heatmap.standardOptions.withUnit('none')
      + options.withCalculate(true)
      + options.calculation.yBuckets.scale.withLog(2)
      + options.calculation.yBuckets.scale.withType('log')
      + options.color.withScheme('RdYlGn')
      + options.yAxis.withUnit('s'),
  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,

    base(title, targets, unit):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.standardOptions.withUnit(unit)
      + timeSeries.fieldConfig.defaults.custom.withLineInterpolation('smooth'),

    tableLegend(title, targets, unit):
      self.base(title, targets, unit)
      + g.panel.timeSeries.options.legend.withDisplayMode('table')
      + g.panel.timeSeries.options.legend.withPlacement('right')
      + g.panel.timeSeries.options.legend.withCalcs(['max', 'mean', 'min'])
      + g.panel.timeSeries.options.legend.withSortBy(['max']),
  },
}
