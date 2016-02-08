require "yaml"
require "http"
require "./utils"

class AuthorizationHandler < HTTP::Handler
  BASIC = "Basic"
  AUTH  = "Authorization"

  def initialize(@config_dir = "./config")
    @permissions_file = File.join(@config_dir, "permissions.yml")
    @free_url_file = File.join(@config_dir, "free.txt")
    # super
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
        if users.find { |u| u as String == username || u as String == "*" }
          return true
        else
          if item.has_key?("children")
            children = item["children"] as Array(YAML::Type)
            children.each do |c|
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

  def authorized?(path : String, username : String)
    begin
      permissions = YAML.load(File.read(@permissions_file as String)) as Hash
    rescue
      return :invalid_permissions_file
    end

    items = path.split("/")
    items[0] = "root"
    authorized = has_access?(permissions, items, username)
    authorized
  end

  # if the user has the permission to see the page, show it.
  # else 403.
  def call(request)
    return call_next(request) if request.path == "/"
    request_path = request.path.not_nil!.gsub("%20"," ")
    request.path = request_path
    value = request.headers[AUTH]?
    # value.try &.size
    if value && value.size > 0 && value.starts_with?(BASIC)
      username, password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")

      result = authorized?(request_path, username)
      # We know that the password matches, look for authorization.
      if result == :invalid_permissions_file
        return HTTP::Response.new(500, "Invalid YAML file: permissions.yml")
      elsif result
        # if authorized, call next.
        return call_next(request)
      else
        # if authenticated but not authorized, 403.
        return render_403
        # super
      end # end of authorized check
    end   # end of header check.
    return render_401
  end
end
