require "yaml"
require "http"
require "./utils"

class HookHandler < HTTP::Handler
  def initialize(@hook_env_name = "WEBHOOK_PATH", @default_url = "/zefkenfjebkaenfanfeanf3rmk3nrk3nj3")
    @logger = Kemal::Logger.new
  end

  def call(request)
    request_path = request.path.not_nil!
    # If this is a hook, start build.
    webhook_path = ENV[@hook_env_name] ||= @default_url
    if request_path.strip == webhook_path
      @logger.write("Hook received on #{webhook_path}. Build is starting...")
      return start_build
    end
    return call_next(request)
  end
end
