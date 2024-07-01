// variables.jsonnet

local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

// Doc: https://grafana.github.io/grafonnet/API/dashboard/variable.html
{
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

  gloo_ext_cluster:
    var.query.new('gloo_ext_cluster')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'envoy_cluster_name',
      metric='envoy_cluster_external_upstream_rq',
    )
    + var.query.refresh.onLoad()
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),
}
