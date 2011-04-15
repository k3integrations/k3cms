module K3
  module Authorization
    class PermissionSet
      attr_reader :name, :description
      attr_reader :guest, :user, :manager, :admin
      
      def initialize(name,description)
        @name, @description = name, description
        @guest, @user, @manager, @admin = [].to_set, [].to_set, [].to_set, [].to_set
      end
      
      def add_abilities(role,abilities)
        var = "@#{role}"
        new_list = abilities.is_a?(Array) || abilities.is_a?(Set) ? abilities : [abilities]
        current_list = instance_variable_get(var)
        instance_variable_set(var,current_list + new_list)
      end
    end
  end
end
