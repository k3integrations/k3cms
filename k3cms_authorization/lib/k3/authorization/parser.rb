module K3
  module Authorization
    class Parser
      class ExtendPermissionSet
        def initialize(perm_set,parser)
          @perm_set, @parser = perm_set, parser
          @local_abilities = {:guest => [].to_set, :user => [].to_set, :manager => [].to_set, :admin => [].to_set}
        end
        
        # Note:  Each role should be called in dependent order, and only once each (if dependency is used)
        def guest(role_abilities)
          @perm_set.add_abilities(*expand_abilities(:guest,role_abilities))
        end
        
        def user(role_abilities)
          @perm_set.add_abilities(*expand_abilities(:user,role_abilities))
        end
        
        def manager(role_abilities)
          @perm_set.add_abilities(*expand_abilities(:manager,role_abilities))
        end
        
        def admin(role_abilities)
          @perm_set.add_abilities(*expand_abilities(:admin,role_abilities))
        end
        
        private
        
        def expand_abilities(role,abilities)
          raise(InvalidPermission, "Must supply a hash when defining permissions") unless abilities.is_a?(Hash)
          if abilities.has_key?(:has)
            abilities[:has] = [abilities[:has]] unless abilities[:has].is_a?(Array)
            full_abilities = abilities[:has].each do |a| 
              @local_abilities[role] += @parser.expand_context!(a)
            end
          end
          if abilities.has_key?(:includes_role)
            abilities[:includes_role] = [abilities[:includes_role]] unless abilities[:includes_role].is_a?(Array)
            abilities[:includes_role].each do |has_role|
              raise(InvalidPermission, "Can't include abilities from #{has_role}; None found") if @local_abilities[has_role].empty?
              @local_abilities[role] += @local_abilities[has_role]
            end
          end
          [role, @local_abilities[role]]
        end
      end
      
      def initialize(auth_set)
        @auth_set = auth_set
        @context = [{:desc => '', :abilities => []}]
      end
      
      def suggested_permission_set(name, description)
        @auth_set.suggested_permission_sets[name] = PermissionSet.new(name, description)
      end
      
      def context(name)
        @context.push :desc => name.to_s.singularize, :abilities => []
        yield
        @context.pop
      end
      
      def ability(name, description)
        raise(InvalidAbility,'Cannot use :all as an ability name') if name==:all
        raise(InvalidAbility, 'Must supply an ability name') if name.blank?
        full_name = expand_context(name).first
        @auth_set.abilities[full_name] = description
        @context.last[:abilities] << full_name
      end
      
      def extend_suggested_permission_set(name, &blk)
        perm_set = @auth_set.suggested_permission_sets[name]
        raise SuggestedPermissionSetUndefined unless perm_set
        change = ExtendPermissionSet.new(perm_set, self)
        change.instance_exec(&blk)
      end
      
      def expand_context(name)
        if (name == :all)
          @context.last[:abilities]
        else
          context_string = @context.collect {|c| c[:desc]}.join('_')
          [(name.to_s + context_string).to_sym]
        end
      end
      
      def expand_context!(name)
        expand_context(name).each do |a|
          raise(AbilityUndefined,"Could not find ability: #{a}") unless @auth_set.abilities.has_key?(a)
        end
      end
    end
  end
end
