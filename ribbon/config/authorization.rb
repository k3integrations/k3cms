K3cms::Ribbon::Railtie.authorization.draw do
  # First define and describe some suggested permission sets.
  suggested_permission_set :default, 'Allows managers and admins to view the ribbon'
  
  # Context makes all abilities defined within to be prefixed with the
  # singularized version of the given string.  Contexts can be nested.
  context :ribbon do
    ability :view, 'Can view the ribbon'  # Creates :view_ribbon ability
    
    # This defines the abilities for the default suggested permission set 
    extend_suggested_permission_set :default do
      manager :has => :view
      # :all only applies to the abilities in this context (:ribbon)
      admin :has => :all
    end
  end
end
