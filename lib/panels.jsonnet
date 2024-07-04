// panels.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

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
}