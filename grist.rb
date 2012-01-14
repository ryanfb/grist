require 'sinatra'
require 'sinatra_auth_github'
require 'yaml'
require 'haml'
require 'pp'
require 'rest_client'
require 'xapian-fu'
require 'singleton'

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
    # self.update
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

class GistList
  include Singleton

  YAML_PATH = 'gists.yml'
  attr_accessor :gists, :github_user
  attr_reader :fetch_progress

  def initialize
    if File.exists?('gists.yml')
      puts "Loading from YAML"
      @gists = YAML.load_file('gists.yml')
      @fetch_progress = 100
    else
      @gists = []
      @fetch_progress = 0
    end
  end

  def update
    if @gists.length == 0
      fetch_all_gists
    end
  end

  def add_gists(gists)
    @gists += gists
    self.save
  end

  def save
    puts "Saving YAML"
    File.open(YAML_PATH, 'w') {|f| f.write(YAML.dump(@gists))}
  end
  
  def build_xapian_db
    db = XapianFu::XapianDb.new(:dir => 'gists.db', :create => true,
                                :store => [:id, :filename, :content])
    @gists.each do |gist|
      gist.update
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

  def fetch_gist_page(gist_page)
    puts "Fetching page #{gist_page}"
    response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_user.token, :page => gist_page }, :accept => :json)
    gists = JSON.parse(response)
    GistList.instance.add_gists(gists.map{|gist_hash| Gist.new(gist_hash)})
  end

  def fetch_all_gists
    response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_user.token }, :accept => :json)
    gists = JSON.parse(response)
    pages = response.headers[:link].scan(/(\d+)>; rel="last"$/).first.first.to_i
    puts "Pages: #{pages}"
    GistList.instance.add_gists(gists.map{|gist_hash| Gist.new(gist_hash)})
    (2..pages).each do |page|
      fetch_gist_page(page)
      @fetch_progress = ((page.to_f / pages.to_f) * 100).to_i
    end
  end
end

helpers do
  def repos
    github_request("user/repos")
  end
  def gists
    GistList.instance.gists
  end
end

get '/' do
  authenticate!
  GistList.instance.github_user = github_user

  haml :index
end

get '/update' do
  authenticate!
  GistList.instance.github_user = github_user

  GistList.instance.update
  "OK!"
end

get '/fetch_progress' do
  GistList.instance.fetch_progress.to_s
end

get '/logout' do
  logout!
  redirect 'https://github.com'
end
