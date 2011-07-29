# encoding: utf-8
require 'rubygems'
require 'net/http'
require 'open/uri'
require 'sinatra'
require 'data_mapper'
require 'active_support/core_ext'
require 'delayed_job'
require 'delayed_job_data_mapper'

class Page
  include DataMapper::Resource
  
  property :id,       Serial
  property :url,      String
  property :data,     Text,       :required => false
  property :pending,  Boolean,    :default => true
  
  after :create do
    Delayed::Job.enqueue self
  end
  
  def prepare
    begin
      u = open self.url
      self.data    = u.string
      self.pending = false
      self.save
    rescue
      # failed to open the url ...
    end
  end
end

before do
  @page = { :title => "DJMapper", :subtitle => "Delayed::Job, DataMapper & Sinatra" }
end


get "/" do
  erb :index
end

post "/url" do
  url_expression = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  
  if params[:url].match url_expression
    @page[:page] = Page.create :url => params[:url]
  else
    @page[:error] = "Invalid URL"
  end

  erb :index
end

DataMapper.setup :default, YAML.load(File.new("config/database.yml"))[:development]
DataMapper.finalize
DataMapper.auto_upgrade!
Delayed::Worker.backend = :data_mapper