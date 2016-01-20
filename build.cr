require "http"
require "logger"
require "colorize"

APP_LOCATION = __DIR__
APP_PUBLIC   = File.join(APP_LOCATION, "/public")
BUILT_PUBLIC = "/tmp/hugo-public"
DROPBOX_PATH = File.join(ENV["HOME"], "Dropbox")
# If you want to use root folder, use empty string.
DOCS_REL_PATH = ENV["DROPBOX_DOCS_REL_PATH"]? ? ENV["DROPBOX_DOCS_REL_PATH"] as String : "/"
DOCS_PATH     = File.join(DROPBOX_PATH, DOCS_REL_PATH)
DOCS_MAKE     = File.join(DOCS_PATH, "/Makefile")

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.info("App path: #{APP_LOCATION}")
log.info("Dropbox path: #{DROPBOX_PATH}")
log.info("Docs relative path: #{DOCS_PATH}")
log.info("Makefile path: #{DOCS_MAKE}")

unless File.exists?(DROPBOX_PATH)
  log.error("Dropbox folder does not exist. Make sure you have installed Dropbox.")
end

if File.exists?(DOCS_MAKE)
  log.info("Makefile in Dropbox folder found, updating...")
  Process.run("make", ["clean"], chdir: DOCS_PATH)
  Process.run("make", ["html"], chdir: DOCS_PATH)
  Process.run("rm", ["-rf", APP_PUBLIC])
  Process.run("cp", ["-rf", BUILT_PUBLIC, APP_PUBLIC], chdir: DOCS_PATH)
  Process.run("cp", ["-rf", "config", File.join(APP_LOCATION, "config")], chdir: DOCS_PATH)
  log.info("Build complete. Output is on #{BUILT_PUBLIC}".colorize(:green))
else
  log.info("Makefile in Dropbox folder not found. Please provide Makefile.")
end
