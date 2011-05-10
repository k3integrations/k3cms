module K3cms
  module Ribbon
    module ControllerMethods
      extend ActiveSupport::Concern

      def set_edit_mode
        if params[:edit].present?
          session[:edit_mode] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:edit])
        end
      end

      def edit_mode?
        # This wouldn't work if we ever wanted GuestUser's to be able to edit too (like a wiki), but this works for now...
        if session[:edit_mode] && K3cms::Authorization::GuestUser === k3cms_user
          Rails.logger.debug "... Logged in as guest. Resetting edit_mode to false."
          session[:edit_mode] = false
        end
        session[:edit_mode] = false if session[:edit_mode].nil?
        session[:edit_mode]
      end

      included do
        helper_method :edit_mode?
      end
    end
  end
end
