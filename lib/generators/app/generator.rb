# Compare: generators/test_app/generator.rb and lib/generators/app/generator.rb
# TODO: Remove duplication
require Pathname.new(__FILE__).dirname + '../base_generator'

module K3cms
  module Generators
    class AppGenerator < BaseGenerator

      source_root Pathname.new(__FILE__).dirname + 'templates'

      argument     :app_name,
                   :desc => "The name of the Rails app to generate.",
                   :type => :string

      class_option :extra_gems,
                   :desc => "A space-seperated list of extra gems to add to the Gemfile and install (for example, '--gems=k3cms_blog k3cms_s3_podcast').",
                   :type => :array,
                   :default => [],
                   :aliases => ['--gems']

      class_option :authentication,
                   :desc => "Which authentication library to install. Options are 'devise' or 'none'.",
                   :type => :string,
                   :default => "devise",
                   :aliases => ['--auth']

      class_option :authorization,
                   :desc => "Which authorization library to use. Known options are 'k3cms_trivial_authorization', 'k3cms_spree_authorization'.",
                   :type => :string,
                   :default => "k3cms_trivial_authorization"

      class_option :k3cms_edge,
                   :desc => "Use the latest edge version from git://github.com/k3integrations/k3cms.git instead of from rubygems.org",
                   :type => :boolean,
                   :default => false

      def generate_app
        args = ['rails', 'new', app_name] + ARGV + ['--skip-prototype', '--skip-test-unit']
        puts args.join(' ')
        system(*args)
      end

      # Note: You still need to remember to do in_root any time you do a run command
      def change_root_to_test_app
        self.destination_root = Pathname.new(destination_root) + "#{app_name}"
      end

      #----------------------------------------------------------------------------------------------
      # View stuff

      def tweak_layout
        gsub_file 'app/views/layouts/application.html.erb', %r(</head>) do |match|
          "  <%= hook :head %>\n" +
          "  <%= content_for :head %>\n" +
          match
        end
        gsub_file 'app/views/layouts/application.html.erb', %r(<body>) do |match|
          match + "\n" +
          "  <%= hook :top_of_page %>\n" +
          "  <%= k3cms_ribbon %>\n"
        end
      end

      def get_jquery_and_set_as_default_js_library
        # Download latest jQuery.min
        get "http://code.jquery.com/jquery-latest.min.js", "public/javascripts/jquery.js"

        # Download latest jQuery drivers
        get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

        #application 'config.action_view.javascript_expansions[:defaults] = %w(jquery rails)'
        gsub_file 'config/application.rb',
          %r( *#? *config.action_view.javascript_expansions\[:defaults\].*$) do |match|
              '    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)'
        end
      end

      def remove_unneeded_files
        silence_stream(STDOUT) do
          remove_file "public/images/rails.png"
          remove_file "public/index.html"
        end
      end

      #----------------------------------------------------------------------------------------------
      # Gems and framework installation

      def add_initial_gems_to_gemfile
        gem 'mysql2', '~> 0.2.7'

        #gem 'rspec-rails', :group => :test

        if authentication_library == 'devise'
          # Workaround for this error:
          # Started GET "/users/sign_up"
          # ActionView::Template::Error (no such file to load -- ruby-debug):
          gsub_file 'Gemfile', 
         %r(^# gem 'ruby-debug19'.*$) do |match|
            "gem 'ruby-debug19', :require => 'ruby-debug', :group => :development"
          end
          gem 'devise'
        end

        in_root do
          run 'bundle install >/dev/null'
        end
      end

      def install_devise
        if authentication_library == 'devise'
          generate 'devise:install'
          generate 'devise', 'User'
          gsub_file 'app/models/user.rb', 
         %r(class User < ActiveRecord::Base$) do |match|
            match + "\n" +
           "  include K3cms::Authorization::RealUser\n"
          end
        end
      end

      def add_remaining_gems_to_gemfile
        gem 'k3cms', k3cms_gem_options('k3cms')

        if authorization_library
          gem authorization_library, k3cms_gem_options(authorization_library)
        end

        extra_gems.each do |extra_gem|
          gem extra_gem, k3cms_gem_options(extra_gem)
        end
      end

      def bundle_install
        in_root do
          run 'bundle install'
        end
      end

      def k3cms_install
        rake 'k3cms:install'
      end
      
      #----------------------------------------------------------------------------------------------

      def set_up_database
        rake 'db:migrate db:seed'
      end

      def git_init
        in_root do
          git :init
          git :add => "."
          git :commit => "-a -m 'Initial commit' >/dev/null"

          rake 'about'
          puts "Application created."
        end
      end

    private
      def authentication_library
        options[:authentication]
      end

      def authorization_library
        options[:authorization]
      end

      def extra_gems
        options[:extra_gems]
      end

      def k3cms_gem_options(gem_name)
        (gem_opts = {}).tap do
          gem_opts.merge! :git => "git://github.com/k3integrations/#{gem_name}.git" if options[:k3cms_edge] && gem_name =~ /^k3cms/
        end
      end

    end
  end
end
