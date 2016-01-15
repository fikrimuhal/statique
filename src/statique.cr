require "./statique/*"
require "kemal"
require "base64"


module Statique
  #basic_auth "username", "password"
  # Matches GET "http://host:port/"
  FREE_URLS = ["/zefkenfjebkaenfanfeanf3rmk3nrk3nj3", "/hello"]

  get "/hello" do
    "hello"
  end

  #get "/zefkenfjebkaenfanfeanf3rmk3nrk3nj3" do
  #  start_build
  #end
end
