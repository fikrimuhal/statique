require "./statique/*"
require "kemal"
require "base64"

if ENV["DROPBOX_DOCS_REL_PATH"]?
  dropbox_path = File.join(ENV["HOME"], "Dropbox")
  # If you want to use root folder, use empty string.
  docs_rel_path = ENV["DROPBOX_DOCS_REL_PATH"]
  docs_path = File.join(dropbox_path, docs_rel_path)
  config_dir = File.join(docs_path, "/config/")
elsif ENV["WEBHOOK_PATH"]?
  config_dir = "/repo/config/" as String
else
  config_dir = "./config/" as String
end

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
