defmodule GatewayService.CircuitBreaker do

  def start do
    ExternalService.start(fuse_name, fuse_options)
  end

end
