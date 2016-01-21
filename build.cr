require "http"
require "logger"
require "colorize"


APP_LOCATION    = __DIR__
APP_PUBLIC      = File.join(APP_LOCATION, "/public")
BUILT_PUBLIC    = "/tmp/hugo-public"
PRIVATE_KEY_URL = ENV["PRIVTE_KEY_URL"]? ? ENV["PRIVTE_KEY_URL"] as String : ""
PUBLIC_KEY_URL  = ENV["PUBLIC_KEY_URL"]? ? ENV["PUBLIC_KEY_URL"] as String : ""
ENV_GIT_REPO    = ENV["GIT_REPO"]?

log = Logger.new(STDOUT)
log.level = Logger::INFO
log.info("App location: #{APP_LOCATION}")

unless ENV_GIT_REPO
  log.warn("No Git repo path provided with GIT_REPO environment variable.".colorize(:red))
  git_repo = "https://github.com/fikrimuhal/hugo-sample"
  gitdir_path = "/tmp/git_repo"
  log.info("Default git repo: #{git_repo}, will download to #{gitdir_path}")
else
  git_repo = ENV_GIT_REPO
  gitdir_path = "/repo"
  log.info("Git repo: #{git_repo}, will download to #{gitdir_path}")

  unless File.exists?("/root/.ssh/id_rsa")
    log.info("No SSH Key exists, now downloading them...")
    Process.run("mkdir", ["/root/.ssh"])
    private_key = HTTP::Client.get(PRIVATE_KEY_URL).body
    public_key = HTTP::Client.get(PUBLIC_KEY_URL).body
    File.write("/root/.ssh/id_rsa", private_key)
    File.write("/root/.ssh/id_rsa.pub", public_key)
    Process.run("chmod", ["600", "/root/.ssh/id_rsa", "/root/.ssh/id_rsa.pub"])
    File.open("/etc/ssh/ssh_config", "a") do |file|
      "StrictHostKeyChecking no".to_s file
    end
  end
end

if File.exists?(gitdir_path)
  log.info("Repo found, updating...")
  Process.run("make", ["clean"], chdir: gitdir_path)
  Process.run("git", ["checkout", "--", "."], chdir: gitdir_path)
  Process.run("git", ["pull"], chdir: gitdir_path)
  Process.run("make", ["html"], chdir: gitdir_path)
  Process.run("rm", ["-rf", APP_PUBLIC])
  Process.run("cp", ["-rf", BUILT_PUBLIC, APP_PUBLIC], chdir: gitdir_path)
  Process.run("cp", ["-rf", "config", File.join(APP_LOCATION, "config")], chdir: gitdir_path)
  log.info("Update complete.".colorize(:green))
else
  log.info("Repo not found, cloning...")
  Process.run("git", ["clone", git_repo as String, gitdir_path as String])
  Process.run("make", ["html"], chdir: gitdir_path)
  Process.run("rm", ["-rf", APP_PUBLIC])
  Process.run("cp", ["-rf", BUILT_PUBLIC, APP_PUBLIC], chdir: gitdir_path)
  Process.run("cp", ["-rf", "config", File.join(APP_LOCATION, "config")], chdir: gitdir_path)

  log.info("Build complete...".colorize(:green))
end
