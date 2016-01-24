require "http"
require "logger"
require "colorize"

APP_LOCATION = __DIR__
APP_PUBLIC   = File.join(APP_LOCATION, "/public")
BUILT_PUBLIC = "/tmp/hugo-public"
DROPBOX_PATH = File.join(ENV["HOME"], "Dropbox")
HUGO_SKEL_PATH = File.join(DROPBOX_PATH, "hugo-skeleton")
HUGO_PATH = "/tmp/hugo"
HUGO_CONTENT_PATH = File.join(HUGO_PATH, "content")
HUGO_MAKEFILE     = File.join(HUGO_PATH, "/Makefile")

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.info("App path: #{APP_LOCATION}")
log.info("Dropbox path: #{DROPBOX_PATH}")
log.info("Makefile path: #{HUGO_MAKEFILE}")

unless File.exists?(DROPBOX_PATH)
  log.error("Dropbox folder does not exist. Make sure you have installed Dropbox.")
end

# Copy Hugo project without content.
Process.run("rm", ["-rf", HUGO_PATH])
Process.run("cp", ["-rf", HUGO_SKEL_PATH, HUGO_PATH])

def copy_dropbox_hugo_content(path)
  if path.strip.size > 0
    from_path = File.join(DROPBOX_PATH, path)
    to_path = File.join(HUGO_CONTENT_PATH, path)
    Process.run("cp", ["-rf", from_path, to_path])
  end
end

# Copy Markdown content to Hugo project's content folder.
include_paths = File.join(HUGO_PATH, "config", "include.txt")
paths = File.read(include_paths).split("\n")
paths.each { |path| copy_dropbox_hugo_content(path) }
copy_dropbox_hugo_content("_index.md")


if File.exists?(HUGO_MAKEFILE)
  log.info("Makefile found, building...")
  Process.run("make", ["clean"], chdir: HUGO_PATH)
  Process.run("make", ["html"], chdir: HUGO_PATH)
  Process.run("rm", ["-rf", APP_PUBLIC])
  Process.run("cp", ["-rf", BUILT_PUBLIC, APP_PUBLIC])
  Process.run("cp", ["-rf", "config", APP_LOCATION], chdir: HUGO_PATH)
  log.info("Build complete. Output is on #{BUILT_PUBLIC}".colorize(:green))
else
  log.info("Makefile in Dropbox hugo-skeleton folder not found. Please provide Makefile.")
end
