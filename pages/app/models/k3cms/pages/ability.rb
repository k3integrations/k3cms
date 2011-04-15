module K3cms
  module Pages
    class Ability
      include CanCan::Ability

      def initialize(user)
        if user.k3cms_permitted?(:view_page)
          can :read, K3cms::Page
        end

        if user.k3cms_permitted?(:edit_page)
          can :read, K3cms::Page
          can :update, K3cms::Page
        end

        if user.k3cms_permitted?(:edit_own_page)
          can :read, K3cms::Page
          can :update, K3cms::Page, :author_id => user.id
        end

        if user.k3cms_permitted?(:create_page)
          can :create, K3cms::Page
        end

        if user.k3cms_permitted?(:delete_page)
          can :destroy, K3cms::Page
        end

        if user.k3cms_permitted?(:delete_own_page)
          can :destroy, K3cms::Page, :author_id => user.id
        end
      end
    end
  end
end
