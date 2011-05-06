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
        session[:edit_mode] = false if session[:edit_mode].nil?
        session[:edit_mode]
      end

      included do
        helper_method :edit_mode?
      end
    end
  end
end
