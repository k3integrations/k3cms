# Compare: generators/test_app/generator.rb and lib/generators/app/generator.rb
# TODO: Remove duplication
require Pathname.new(__FILE__).dirname + '../base_generator'

module K3cms
  module Generators
    class TestAppGenerator < BaseGenerator

      class_option :app_name,
                   :type => :string,
                   :desc => "The name of the Rails app to generate. (Default is 'test_app')",
                   :default => "test_app"

      # source_root is not inherited by subclasses, but source_paths is in a sense (source_paths_for_search looks at from_superclass(:source_paths, [])). That's we used source_paths instead of source_root.
      #source_root Pathname.new(__FILE__).dirname + 'templates'
      def self.source_paths
        [ Pathname.new(__FILE__).dirname + 'templates' ]
      end

      def generate_app
        silence_stream(STDOUT) do
          remove_directory_recursively("spec/#{app_name}")
          inside "spec" do
            # TODO: remove duplication with AppGenerator by invoking the normal AppGenerator here and then tweaking generated app below
            # AppGenerator.start(["--k3cms-path", k3cms_path, '--extra-gems', k3cms_gems_from_subclass])

            run "rails new #{app_name} --skip-git --skip-prototype --skip-test-unit --skip-gemfile --quiet"
          end
        end
      end

      #----------------------------------------------------------------------------------------------
      def change_root_to_test_app
        self.destination_root = Pathname.new(destination_root) + "spec/#{app_name}"
      end

      def remove_unneeded_files
        silence_stream(STDOUT) do
          remove_file "doc"
          remove_file "lib/tasks"
          remove_file "public/images/rails.png"
          remove_file "public/index.html"
          remove_file "README"
          remove_file "vendor"
        end
      end

      # TODO: Remove duplication
      def install_devise
        # We need a Gemfile in the test_app, but it shouldn't reference any K3cms gems yet, because some of those k3cms Engines have a user_decorator.rb which requires the User model to exist already, and it does not.
        in_root do
          create_bootstrap_test_app_gemfile_for_devise
          bundle_install

          # We could use the generate method supplied by Rails, but that swallows stdout, which makes debuging difficult
          #generate 'devise:install'
          #generate 'devise', 'User'
          run_ruby_script "script/rails generate devise:install #{to_stderr_if_verbose}", :verbose => verbose
          run_ruby_script "script/rails generate devise User    #{to_stderr_if_verbose}", :verbose => verbose
          gsub_file 'app/models/user.rb', 
         %r(class User < ActiveRecord::Base$) do |match|
            match + "\n" +
           "  include K3cms::Authorization::RealUser\n"
          end
        end
      end

      # Now that we've bootstrapped all dependencies, we can just point to the Gemfile in the gem root.
      def create_test_app_gemfile
        create_file "Gemfile", <<-End, :force => true
eval(File.read(Pathname.new(__FILE__).dirname + "../../Gemfile"), binding, __FILE__, __LINE__)
End
        bundle_install
      end

      def rake_k3cms_install
        inside "test_app" do
          run 'rake k3cms:install'
        end
      end

      def create_databases_yml
        template "config/database.yml", "config/database.yml", :force => true
      end

      def run_migrations
        inside "." do
          silence_stream(STDERR, :unless_verbosity_gte => 1) do
            # drop and recreate database, if necessary (if they're using mysql)
            run "rake #{'db:drop db:create' if db_create?} " +
                     "db:migrate db:seed RAILS_ENV=test     #{to_stderr_if_verbose}"
            run "rake db:migrate db:seed RAILS_ENV=cucumber #{to_stderr_if_verbose}"
          end
        end
      end

    protected

      def bundle_install
        in_root do
          run "bundle install #{to_stderr_if_verbose}"
        end
      end

      def create_bootstrap_test_app_gemfile_for_devise
        # override in subclass
      end

    private

      def app_name
        options[:app_name]
      end

      def db_create?
        false
      end

    end
  end
end
