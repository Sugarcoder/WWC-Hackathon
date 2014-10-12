  source 'https://rubygems.org'

gem 'rails', '4.1.1'

gem 'pg' # Use postgresql as the database for Active Record
gem 'sass-rails', '~> 4.0.3' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'turbolinks' # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jbuilder', '~> 2.0' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'sdoc', '~> 0.4.0', group: :doc # bundle exec rake doc:rails generates the API under doc/api.
gem 'spring', group: :development
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'

# gem 'therubyracer',  platforms: :ruby # See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'bcrypt', '~> 3.1.7' # Use ActiveModel has_secure_password
# gem 'unicorn' # Use unicorn as the app server
# gem 'capistrano-rails', group: :development # Use Capistrano for deployment
# gem 'debugger', group: [:development, :test] # Use debugger

gem 'high_voltage' #static page creator
gem 'devise'

gem 'autoprefixer-rails'
gem "cancancan" # authorization gem
gem 'premailer-rails'
gem 'acts_as_commentable_with_threading'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap' # bootstrap css with will_paginate
gem 'aws-sdk'
gem 'paperclip'
gem 'redis'
gem 'sidekiq'

#bootstrap
gem 'bootstrap-sass', '~> 3.2.0'
gem 'momentjs-rails', '>= 2.8.1'
gem 'bootstrap3-datetimepicker-rails', '~> 3.0.2'
gem 'bootstrap-validator-rails'



group :production do
  gem 'rails_12factor'
  gem 'informant-rails'
  gem 'appsignal'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'email_spec'
  gem 'test_after_commit'
  gem 'poltergeist'
  gem 'growl'
  gem 'bullet' #check for N+1 queries
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'quiet_assets' # stop print asset in console
  gem 'guard-rspec'
end

gem 'unicorn'
gem 'sinatra', require: false
gem 'slim'