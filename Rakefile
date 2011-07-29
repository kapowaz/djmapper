require 'rubygems'
require 'data_mapper'
require 'active_support/core_ext'
require 'delayed_job'
require 'delayed_job_data_mapper'

namespace :jobs do
  desc "Start DelayedJob worker"
  task :work do    
    DataMapper.setup :default, YAML.load(File.new("config/database.yml"))[:development]
    DataMapper::Logger.new($stdout, :info)
    Delayed::Worker.backend = :data_mapper
    Delayed::Job.auto_migrate!
    Delayed::Worker.new.start
  end
end