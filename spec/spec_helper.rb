require 'facets'
require 'rails'
require 'action_pack'
require 'action_view/railtie' # so that config.action_view is available in engine.rb
require 'active_record'       # Make sure this gets required before attribute_normalizer
Bundler.require(:default, :development)
require 'k3_authorization'
require 'k3/authorization/drivers/devise'

require File.expand_path('../../lib/k3_pages', __FILE__)

require 'connection_and_schema'

require 'k3/authorization/drivers/devise'

## Devise must initialize first, so use the following hook.
#module ActionDispatch::Routing
#  class RouteSet #:nodoc:
#    def finalize_with_my_app!
#      finalize_without_my_app!
#      Cell::Base.send :include, Devise::Controllers::Helpers
#      Cell::Base.send :include, K3::Authorization::Drivers::Devise
#      Cell::Base.send :include, K3::Authorization::GeneralControllerMethods
#      ApplicationController.send :include, K3::Authorization::Drivers::Devise
#      ApplicationController.send :include, K3::Authorization::GeneralControllerMethods
#    end
#    alias_method_chain :finalize!, :my_app
#  end
#end

module TestApp
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
  end
end
TestApp::Application.initialize!

require 'devise'
require 'devise/orm/active_record'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  include K3::Authorization::RealUser
end

#---------------------------------------------------------------------------------------------------
#puts Rails.application.routes.routes

# See http://openhood.com/rails/rails%203/2010/07/20/add-routes-at-runtime-rails-3/
begin
  _routes = TestApp::Application.routes
  _routes.disable_clear_and_finalize = true
  _routes.clear!
  TestApp::Application.routes_reloader.paths.each{ |path| load(path) }
  _routes.draw do
    devise_for :users
  end
  ActiveSupport.on_load(:action_controller) { _routes.finalize! }
ensure
  _routes.disable_clear_and_finalize = false
end

#puts ... after:'
#puts Rails.application.routes.routes

#---------------------------------------------------------------------------------------------------
require 'action_controller'
class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end
ApplicationController.send :include, K3::Authorization::Drivers::Devise
ApplicationController.send :include, K3::Authorization::GeneralControllerMethods

require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include AttributeNormalizer::RSpecMatcher
end
