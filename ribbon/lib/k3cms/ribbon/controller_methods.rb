module K3cms
  module Ribbon
    module ControllerMethods
      extend ActiveSupport::Concern

      def set_edit_mode
        if params[:edit].present?
          cookies[:edit_mode] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:edit])
        end
      end

      def edit_mode?
        # This is a workaround to allow us to use this helper from within Cells. Cells automatically delegates :session to parent_controller but not :cookies.
        cookies = respond_to?(:parent_controller) ? parent_controller.send(:cookies) : cookies()

        # This wouldn't work if we ever wanted GuestUser's to be able to edit too (like a wiki), but this works for now...
        if cookies[:edit_mode] && K3cms::Authorization::GuestUser === k3cms_user
          Rails.logger.debug "... Logged in as guest. Resetting edit_mode to false."
          cookies[:edit_mode] = false
        end
        cookies[:edit_mode] = false if cookies[:edit_mode].nil?
        cookies[:edit_mode]
      end

      included do
        helper_method :edit_mode?
      end
    end
  end
end
