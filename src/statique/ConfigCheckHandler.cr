require "http"

class ConfigCheckHandler < HTTP::Handler
  def initialize(@config_dir = "./config")
    @logger = Kemal::Logger.new
  end

  def call(request)
    unless File.exists?(@config_dir)
      config_dir = @config_dir
      @logger.write("#{config_dir} does not exist. Make proper setup.")
      return HTTP::Response.new(500, "#{config_dir} does not exist. Make proper setup.")
    end
    return call_next(request)
  end
end
