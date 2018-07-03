# Load the Rails application.
require_relative 'application'

require 'delayed_job_mongoid'
require 'sidekiq'

# Initialize the Rails application.
Rails.application.initialize!
