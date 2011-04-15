module K3cms
  module Ribbon
    module ControllerMethods
      def set_edit_mode
        if params[:edit].present?
          session[:edit_mode] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:edit])
        end
      end
    end
  end
end
