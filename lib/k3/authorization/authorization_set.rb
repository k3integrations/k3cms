module K3
  module Authorization
    # AuthorizationSet
    #
    # This object stores a set of abilities (just a hash of :symbol => "Ability Name"),
    # and a set of abilities (a hash of :symbol => PermissionSet object)
    class AuthorizationSet
      attr_accessor :suggested_permission_sets, :abilities
      
      # :nodoc:
      def initialize
        clear!
      end
      
      # Calls runs the given block in the context of the Parser object, so the DSL
      # may be used.  Then freezes the abilities and suggested permission sets it gets.
      def draw(&blk)
        clear!
        parser = Parser.new(self)
        parser.instance_exec(&blk)
        freeze!
      end
      
      # Clears (resets/deletes) the permission sets
      def clear!
        self.suggested_permission_sets = {}
        self.abilities = {}
      end
      
      # Freezes the 
      def freeze!
        suggested_permission_sets.freeze
        abilities.freeze
      end
      
      # Returns the suggested permission set called "default"
      def default_suggested_permission_set
        suggested_permission_sets[:default] or suggested_permission_sets['default']
      end
      
      # Initialization method causing each of the given list of engines to load their
      # authorization.rb config files into AuthorizationSet objects.
      def self.load(engines)
        engines.each do |engine|
          config_file = File.join(engine.config.paths.path,'config','authorization.rb')
          require config_file if File.exists?(config_file)
        end
      end
    end
  end
end
