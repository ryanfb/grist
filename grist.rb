require 'sinatra'
require 'sinatra_auth_github'
require 'yaml'
require 'haml'
require 'pp'
require 'rest_client'

enable :sessions, :logging

config = YAML.load_file('config.yml')

set :github_options, {
                        :secret    => config["secret"], 
                        :client_id => config["client_id"]
                     }

Sinatra.register Sinatra::Auth::Github

def fetch_all_gists
  page = 1
  response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_user.token }, :accept => :json)
  gists = JSON.parse(response)
  while response.headers[:link] =~ /rel..next/ do
    page += 1
    puts "Fetching page #{page}"
    response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_user.token, :page => page }, :accept => :json)
    gists += JSON.parse(response)
  end
  return gists
end


helpers do
  def repos
    github_request("user/repos")
  end
  def gists
    # session[:gists] ||= 
    fetch_all_gists
  end
end

get '/' do
  authenticate!
  puts "test"
  haml :index
end

get '/logout' do
  logout!
  redirect 'https://github.com'
end
