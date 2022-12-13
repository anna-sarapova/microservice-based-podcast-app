import Config

config :gateway_service, port: 8070
config :gateway_service, ip: {:local, "gateway_service"}

config :gateway_service, GatewayService.PromEx,
       manual_metrics_start_delay: :no_delay,
       drop_metrics_groups: [],
       grafana: [
              host: "http://grafana:3000",
              username: "admin",
              password: "admin",
              auth_token: "eyJrIjoiNTQybTY1bjFiTjByck41UE5kdDluek5jODdxcDhjbEoiLCJuIjoiUEFEX2xhYiIsImlkIjoxfQ==",
              upload_dashboards_on_start: true,
              folder_name: "Notes Dashboards",
              annotate_app_lifecycle: true
       ],
       metrics_server: :disabled
