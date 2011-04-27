require File.dirname(__FILE__) + '/../base_generator'

module K3cms
  module Generators
    class TestAppGenerator < BaseGenerator

      class_option :quiet,
                   :type => :boolean,
                   :desc => "Suppress most output from generator",
                   :default => false

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

      def install_devise
        # We need a Gemfile in the test_app, but it shouldn't reference any K3cms gems yet, because some of those k3cms Engines have a user_decorator.rb which requires the User model to exist already, and it does not.
        inside "." do
          create_bootstrap_test_app_gemfile_for_devise
        end
        generate 'devise:install'
        generate 'devise', 'User'
      end

      # Now that we've bootstrapped all dependencies, we can just point to the Gemfile in the gem root.
      def create_test_app_gemfile
        create_file "Gemfile", <<-End, :force => true
eval(File.read(Pathname.new(__FILE__).dirname + "../../Gemfile"), binding, __FILE__, __LINE__)
End
      end

      def create_databases_yml
        template "config/database.yml", :force => true
      end


    protected

      def create_bootstrap_test_app_gemfile_for_devise
        # override in subclass
      end

    private

      def app_name
        options[:app_name]
      end

      def run_migrations
        inside "." do
          silence_stream(STDOUT) {
            run "rake db:migrate db:seed RAILS_ENV=test"
            run "rake db:migrate db:seed RAILS_ENV=cucumber"
          }
        end
      end

    end
  end
end
