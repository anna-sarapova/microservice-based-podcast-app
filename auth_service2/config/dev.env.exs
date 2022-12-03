import Config

config :auth_service2, port: 8081
config :auth_service2, ip: {:local, "auth_service2"}
config :auth_service2, database: "auth_service_db"
config :auth_service2, seeds: ["mongo1:27017", "mongo2:27017", "mongo3:27017"]
config :auth_service2, pool_size: 3