# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  #database cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    if example.metadata[:js] || example.metadata[:type] == 'feature'
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
    example.run
    Capybara.reset_sessions!
  end

  config.append_after(:each) do |example|
    DatabaseCleaner.clean
    $redis.flushdb
  end

  config.infer_spec_type_from_file_location!
end
