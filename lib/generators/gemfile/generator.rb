require File.dirname(__FILE__) + '/../base_generator'

module K3cms
  module Generators
    class GemfileGenerator < BaseGenerator

      class_option :quiet,
                   :type => :boolean,
                   :desc => "Suppress most output from generator",
                   :default => false

      class_option :include_k3cms_gems,
                   :type => :boolean,
                   :desc => "Include \"gem 'k3cms'\", etc. in generated Gemfile",
                   :default => true

      def create_gemfile_in_gem_root
        silence_stream(STDOUT) do
          remove_file "Gemfile.lock"
          template "Gemfile.tt", "Gemfile", :force => true

          if options.include_k3cms_gems
            # Have it point to your local development copies of the k3cms gems using the :path determined in gems_for_gemfile
            append_file 'Gemfile' do
              k3cms_gems_for_gemfile
            end
          end
        end
      end


    protected

      def k3cms_gems_for_gemfile
        # Each gem should override this method with the appropriate list of gems that that gem depends on
      end

    end
  end
end

