#########
# Install K3cms core gems
gem 'k3cms_core'
gem 'rspec-rails', :group => :test
#gem 'ruby-debug19', :require => 'ruby-debug', :group => :development
gem 'mysql2'

if ENV['k3cms_gems']
  gemlist = ENV['k3cms_gems']
else
  gemlist = ask("Enter any extra gems to install, comma separated (Enter for none): ")
end

gemlist.split(/\s*,\s*/).each do |sgem|
  puts "  Installing extra gem: #{sgem}"
  gem sgem
end

#########
# Set default javascript library to jquery instead of prototype
# From: http://github.com/lleger/Rails-3-jQuery/blob/master/jquery.rb

# Download latest jQuery.min
get "http://code.jquery.com/jquery-latest.min.js", "public/javascripts/jquery.js"

# Download latest jQuery drivers
get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

# Override :defaults and setup :jquery expansion
initializer 'jquery.rb', <<-CODE
  ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jquery => ['jquery', 'rails']
  ActiveSupport.on_load(:action_view) do
    ActiveSupport.on_load(:after_initialize) do
      ActionView::Helpers::AssetTagHelper::register_javascript_expansion :defaults => ['jquery', 'rails']
    end
  end
CODE

#########
# Install gems

run 'bundle install'
rake 'k3cms:install'
rake 'db:migrate'

#########
# Setup git repos

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

puts "Application created."
