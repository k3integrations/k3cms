module K3
  module Pages
    class Ability
      include CanCan::Ability

      def initialize(user)
        if user.k3_permitted?(:view_page)
          can :read, K3::Page
        end

        if user.k3_permitted?(:edit_page)
          can :read, K3::Page
          can :update, K3::Page
        end

        if user.k3_permitted?(:edit_own_page)
          can :read, K3::Page
          can :update, K3::Page, :author_id => user.id
        end

        if user.k3_permitted?(:create_page)
          can :create, K3::Page
        end

        if user.k3_permitted?(:delete_page)
          can :destroy, K3::Page
        end

        if user.k3_permitted?(:delete_own_page)
          can :destroy, K3::Page, :author_id => user.id
        end
      end
    end
  end
end
