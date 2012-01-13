require 'sinatra'
require 'sinatra_auth_github'
require 'yaml'
require 'haml'
require 'pp'
require 'rest_client'
require 'xapian-fu'

enable :sessions, :logging

config = YAML.load_file('config.yml')

set :github_options, {
                        :secret    => config["secret"], 
                        :client_id => config["client_id"]
                     }

Sinatra.register Sinatra::Auth::Github

class Gist
  attr_reader :metadata, :id, :path

  def initialize(gist_hash = {})
    @metadata = gist_hash
    @id = @metadata["id"]
    @path = File.join('gists',"#{@id}")
    self.update
  end

  def update
    if !File.directory?(@path)
      self.clone
    else
      command = "git --git-dir=\"#{File.join(@path,'.git')}\" --work-tree=\"#{@path}\" pull"
      puts command
      `#{command}`
    end
  end

  def clone
    command = "git clone \"#{@metadata["git_push_url"]}\" \"#{@path}\""
    puts command
    `#{command}`
  end

  def files
    @metadata["files"].values.collect{|file_hash| file_hash["filename"]}
  end
end

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
  return gists.map{|gist_hash| Gist.new(gist_hash)}
end

def build_xapian_db
  db = XapianFu::XapianDb.new(:dir => 'gists.db', :create => true,
                              :store => [:id, :filename, :content])
  gist_cache.each do |gist|
    gist.files.each do |file|
      contents = File.open(File.join(gist.path, file),"rb") {|f| f.read}
      db << { :id => gist.id, :filename => file, :content => contents}
    end
  end
  db.flush
  db.search("leiden").each do |match|
    puts match.values[:id]
  end
end

helpers do
  def repos
    github_request("user/repos")
  end
  def gist_cache
    if File.exists?('gists.yml')
      puts "Loading from YAML"
      gists = YAML.load_file('gists.yml')
    else
      puts "Fetching gists"
      gists = fetch_all_gists
      File.open('gists.yml', 'w') {|f| f.write(YAML.dump(gists))}
    end
    return gists
  end
  def gists
    # gist_cache.each{|gist| gist.update}
    gist_cache
  end
end

get '/' do
  authenticate!
  build_xapian_db
  puts "test"
  haml :index
end

get '/logout' do
  logout!
  redirect 'https://github.com'
end
