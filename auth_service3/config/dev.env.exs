import Config

config :auth_service3, port: 8082
config :auth_service3, ip: {:local, "auth_service3"}
config :auth_service3, database: "auth_service_db"
config :auth_service3, seeds: ["mongo1:27017", "mongo2:27017", "mongo3:27017"]
config :auth_service3, pool_size: 3