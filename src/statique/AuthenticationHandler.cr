require "yaml"
require "./utils"
require "http"

class AuthenticationHandler < HTTP::Handler
  BASIC = "Basic"
  AUTH  = "Authorization"

  def initialize(@config_dir = "./config")
    @passwords_file = File.join(@config_dir, "passwords.txt")
  end

  def call(request)
    value = request.headers[AUTH]?

    if value && value.size > 0 && value.starts_with?(BASIC)
      username, password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      authenticated? = password_matches?(username, password)
      if authenticated? == :invalid_password_file
        return HTTP::Response.new(500, "Invalid file: passwords.txt")
      elsif authenticated?
        return call_next(request)
      end
    end
    return render_401
  end

  def password_matches?(username : String, password : String)
    begin
      lines = File.read_lines(@passwords_file as String)
      lines.each do |line|
        l = line.split(":")
        us = l[0].strip
        ps = l[1].strip
        return true if username == us && password == ps
      end
    rescue
      return :invalid_password_file
    end
    return false
  end
end
