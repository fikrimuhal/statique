require "yaml"
require "http"
require "./utils"

class FullStaticFileHandler < HTTP::StaticFileHandler
  def initialize(@publicdir)
  end

  def get_static_path(request_path)
    #request_path = request_path.sub("%20", "-").sub(" ", "-")
    if request_path[-1] == '/' # || request_path.size > 1 && request_path[-1] == "/"
      static_path = @publicdir + request_path + "index.html"
    elsif !request_path.ends_with?(".html")
      # TODO: Other extensions will be discarded.
      # TODO: if doesn't have an extension, redirect to url with / at the end if there exists that folder.
      static_path = File.join(@publicdir, request_path, "index.html")
    else
      static_path = File.join(@publicdir, request_path)
    end
    return static_path
  end

  def call(request)
    if request.path.not_nil!
      reqpath = request.path.to_s as String
      reqpath = reqpath.strip
      static_path = get_static_path(reqpath)
      if File.exists?(static_path)
        return HTTP::Response.new(200, File.read(static_path), HTTP::Headers{"Content-Type": mime_type(static_path)})
      end
    end
    # will handle with next handlers.
    return call_next(request)
  end
end
