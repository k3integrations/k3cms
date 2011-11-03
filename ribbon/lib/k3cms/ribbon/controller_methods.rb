# This is a workaround to allow us to use this helper from within Cells. Cells automatically delegates :session to parent_controller but not :cookies.
module Cell
  class Rails
    module Metal
      delegate :cookies, :to => :parent_controller
    end 
  end
end

module K3cms
  module Ribbon
    module ControllerMethods
      extend ActiveSupport::Concern

      def set_edit_mode
        if params[:edit].present?
          cookies[:edit_mode] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:edit])
        end

        if not can_enable_edit_mode?
          Rails.logger.debug "... Insufficient permissions. Resetting edit_mode to false."
          cookies[:edit_mode] = false
        end
        cookies[:edit_mode] = false if cookies[:edit_mode].nil?

        # cookies apparently only stores/returns strings, so convert to boolean
        cookies[:edit_mode] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(cookies[:edit_mode])
      end

      # Returns true if current user has permission to enable edit mode.
      # Used to determine whether to load the JavaScript code required for edit mode.
      # This is looking forward to a brighter day when edit mode can be toggled entirely on the client-side and doesn't require reloading the page.
      def can_enable_edit_mode?
        # This wouldn't work if we ever wanted GuestUser's to be able to edit too (like a wiki), but this works for now...
        if K3cms::Authorization::GuestUser === k3cms_user
          false
        else
          !!k3cms_user
        end
      end

      def edit_mode?
        set_edit_mode
        cookies[:edit_mode]
      end

      included do
        helper_method :can_enable_edit_mode?, :edit_mode?
      end
    end
  end
end
