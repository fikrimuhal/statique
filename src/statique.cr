require "./statique/*"
require "kemal"
require "base64"

config_dir = "./config"

add_handler Kemal::Logger.new
add_handler HookHandler.new("WEBHOOK_PATH")
add_handler ConfigCheckHandler.new(config_dir)
add_handler AuthenticationHandler.new(config_dir)
add_handler AuthorizationHandler.new(config_dir)
add_handler FullStaticFileHandler.new("./public")

module Statique
  get "/hello123" do
    "hello"
  end
end
