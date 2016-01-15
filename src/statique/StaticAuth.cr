require "kemal"
require "yaml"
require "./utils"
class StaticAuthHandler < HTTP::StaticFileHandler
  BASIC = "Basic"
  AUTH  = "Authorization"


  def initialize(@public_dir)
    if ENV["WEBHOOK_PATH"]?
      @config_dir = "/repo/config/" as String
    else
      @config_dir = "./config/" as String
    end
    @passwords_file = @config_dir + "passwords.txt"
    @permissions_file = @config_dir + "permissions.yml"
    @free_url_file = @config_dir + "free.txt"
    super
  end

  # Checks if the given **username** has permission to see the page on **path**
  # by looking at the given **hash** containing paths and allowed user list.
  # this function is recursive, at each step a subfolder is checked by calling
  # the function again.
  def has_access?(hash : Hash(YAML::Type, YAML::Type), path : Array(String), username : String)
    # base case
    return false if path.size == 0
    head = path[0]
    if hash.has_key?(head)
      item = hash[head] as Hash
      if item
        users = item["users"] as Array(YAML::Type)
        if users.find{ | u | u as String == username || u as String == "*" }
          return true
        else
          if item.has_key?("children")
            children = item["children"] as Array(YAML::Type)
            children.each do | c |
              response = has_access?(c as Hash(YAML::Type, YAML::Type), path[1..-1], username)
              return true if response == true
            end
            return false
          else
            return false
          end
        end
      else
        return false
      end
    else
      return false
    end
  end

  def password_matches?(username : String, password : String)
    lines = File.read_lines(@passwords_file as String)
    lines.each do | line |
      l = line.split(":")
      us = l[0].strip
      ps = l[1].strip
      return true if username == us && password == ps
    end
    return false
  end

  def authorized?(path : String, username : String)
    permissions = YAML.load(File.read(@permissions_file as String)) as Hash
    items = path.split("/")
    items[0] = "root"
    authorized = has_access?(permissions, items, username)
    authorized
  end

  def get_static_path(request_path)
      if request_path[-1] == '/'
        static_path = @publicdir + request_path + "index.html"
      elsif !request_path.ends_with?(".html")
        static_path = @publicdir + request_path + "/" + "index.html"
      else
        static_path = @publicdir + request_path
      end
      return static_path
  end

  # Handles requests
  # if the path is among the free to go paths, let next handler handle it.
  # if not, go on.
  # if the headers have authentication info, check it.
  #   if the user is authenticated (correct username + password)
  #       if the user has the permission to see the page, show it.
  #       else 403.
  # else show password prompt to enter the password.
  def call(request)
    request_path = request.path.not_nil!
    # If this is a hook, start build.
    webhook_path = ENV["WEBHOOK_PATH"] ||= "/zefkenfjebkaenfanfeanf3rmk3nrk3nj3"
    if request_path.strip == webhook_path
      return start_build
    end

    unless File.exists?(@free_url_file)
      return start_build
    end

    # If the path is among the free to go paths, allow next handler to handle it.
    free_paths = File.read(@free_url_file as String).split("\n")
    if free_paths.any?{|i| i.compare(request_path)==0}
      return call_next(request)
    end

    value = request.headers[AUTH]?

    if value && value.size > 0 && value.starts_with?(BASIC)
      username, password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      authenticated? = password_matches?(username, password)
      if authenticated?
        # Now that the password matches, look for authorization.
        if authorized?(request_path, username)
          if request.path.not_nil!
            reqpath = request.path.to_s as String
            reqpath = reqpath.strip
            static_path = get_static_path(reqpath)
            if File.exists?(static_path)
              return HTTP::Response.new(200, File.read(static_path), HTTP::Headers{"Content-Type": mime_type(static_path)})
            else
              # will handle with next handlers.
              return call_next(request)
            end
          end
        else
          # if authenticated but not authorized, 403.
          return render_403
          super
        end # end of authorized check
      end # end of authenticated check
    end # end of header check.

    # If no password provided or password is wrong, ask for password.
    headers = HTTP::Headers.new
    headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""
    HTTP::Response.new(401, "Could not verify your access level for that URL.\nYou have to login with proper credentials", headers, nil, "HTTP/1.1", nil)
  end
end

Kemal.config.add_handler StaticAuthHandler.new("./public")
