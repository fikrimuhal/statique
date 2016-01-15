require "./statique/*"
require "kemal"
require "base64"

if ENV["WEBHOOK_PATH"]?
  config_dir = "/repo/config/" as String
else
  config_dir = "./config/" as String
end

add_handler Kemal::Logger.new
add_handler HookHandler.new("WEBHOOK_PATH")
add_handler AuthenticationHandler.new(config_dir)
add_handler AuthorizationHandler.new(config_dir)
add_handler FullStaticFileHandler.new("./public")

module Statique
  get "/hello123" do
    "hello"
  end
end
