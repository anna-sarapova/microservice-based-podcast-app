import Config

config :auth_service, port: 8080
config :auth_service, ip: {:local, "auth_service"}
config :auth_service, database: "auth_service_db"
config :auth_service, seeds: ["mongo1:27017", "mongo2:27017", "mongo3:27017"]
config :auth_service, pool_size: 3