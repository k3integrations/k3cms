module K3cms
  module Authorization
    # General K3cms authorization error
    class Error < StandardError; end
    
    # An ability was used that was not previously defined
    class AbilityUndefined < Error; end
    
    # A suggested permission set was referred to that was not previously defined
    class SuggestedPermissionSetUndefined < Error; end
    
    # A permission was not defined correctly
    class InvalidPermission < Error; end
    
    # An invalid ability name was used
    class InvalidAbility < Error; end
  end
end
