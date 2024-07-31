// panels.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

// Documentation
// Units: https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/valueFormats/categories.ts#L37

{
  heatmap: {
    local heatmap = g.panel.heatmap,
    local options = heatmap.options,

    base(title, targets, unit):
      heatmap.new(title)
      + heatmap.queryOptions.withTargets(targets)
      + heatmap.standardOptions.withUnit(unit)
      + options.withCalculate(true)
      + options.calculation.yBuckets.scale.withLog(2)
      + options.calculation.yBuckets.scale.withType('log')
      + options.color.withScheme('RdYlGn')
      + options.yAxis.withUnit(unit),
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
      + timeSeries.options.legend.withDisplayMode('table')
      + timeSeries.options.legend.withPlacement('right')
      + timeSeries.options.legend.withCalcs(['max', 'mean', 'min'])
      + timeSeries.options.legend.withSortBy(['max']),

    overrideQueryBytes(title, targets, unit):
      self.base(title, targets, unit)
      + {
        fieldConfig: {
          overrides: [
            {
              matcher: {
                id: 'byFrameRefID',
                options: 'A',
              },
              properties: [
                {
                  id: 'custom.axisPlacement',
                  value: 'left',
                },
                {
                  id: 'unit',
                  value: 'percentunit',
                },
              ],
            },
            {
              matcher: {
                id: 'byFrameRefID',
                options: 'B',
              },
              properties: [
                {
                  id: 'custom.axisPlacement',
                  value: 'right',
                },
                {
                  id: 'unit',
                  value: 'bytes',
                },
              ],
            },
          ],
        },
      },
    //+ timeSeries.standardOptions.override.byQuery.new('B')
    //  + timeSeries.standardOptions.override.byQuery.withPropertiesFromOptions(
    //    timeSeries.standardOptions.withUnit('bytes')
    //    + timeSeries.fieldConfig.defaults.custom.withAxisPlacement('right')
    //  ),
  },

  stat: {
    local stat = g.panel.stat,
    local options = stat.options,

    base(title, targets, unit):
      stat.new(title)
      + stat.queryOptions.withTargets(targets)
      + stat.standardOptions.withUnit(unit),
  },
}
