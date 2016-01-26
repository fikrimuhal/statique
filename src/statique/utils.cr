def is_running?(program : String)
  value = Process.run("ps", ["aux"]) do |proc|
    txt = proc.output.gets_to_end
  end
  value = value as String
  value.split("\n").select { |line| line.includes? program }.size > 0
end

def start_build
  unless is_running?("build.py")
    Process.new("python /app/build.py")
    return HTTP::Response.new(202, "Build process started... Please check back later.")
  else
    return HTTP::Response.new(409, "A build process is already active. Did not start a new build.")
    # Todo: have pool.
    # http://stackoverflow.com/questions/7485776/start-script-after-another-one-already-running-finishes
  end
end

def render_401
  # If no password provided or password is wrong, ask for password.
  headers = HTTP::Headers.new
  headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""
  HTTP::Response.new(401, "Could not verify your access level for that URL.\nYou have to login with proper credentials", headers, nil, "HTTP/1.1", nil)
end
