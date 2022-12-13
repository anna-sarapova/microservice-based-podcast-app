defmodule MetricsExporter do
  use Prometheus.PlugExporter
end

#plug MetricsExporter