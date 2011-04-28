require 'rails/generators'

# Reference:
# * http://rubydoc.info/github/wycats/thor/master/Thor/Actions
# * http://rubydoc.info/github/wycats/thor/master/Thor/Actions/ClassMethods
# * http://rdoc.info/github/lifo/docrails/master/Rails/Generators/Base

module K3cms
  module Generators
    class BaseGenerator < Rails::Generators::Base

      class_option :quiet,
                   :type => :boolean,
                   :desc => "Suppress most output from generator",
                   :default => false

    private

      def verbosity
        if options[:quiet]
          0
        elsif options[:verbose]
          2
        else
          1
        end
      end

      def remove_directory_recursively(path)
        silence_stream(STDOUT) do
          run "rm -r #{path}" if Pathname.new(path).directory?
        end
      end

      def silence_stream(stream)
        if verbosity == 0
          yield
        else
          begin
            old_stream = stream.dup
            stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
            stream.sync = true
            yield
          ensure
            stream.reopen(old_stream)
          end
        end
      end
    end
  end
end

