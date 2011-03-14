require 'cancan'

module K3
  module Pages
    class BaseController < ApplicationController
      # Needed for CanCan authorization
      include CanCan::ControllerAdditions

      def current_ability
        @current_ability ||= K3::Pages::Ability.new(k3_user)
      end

      rescue_from CanCan::AccessDenied do |exception|
        k3_authorization_required
      end

      helper K3::InlineEditor::InlineEditorHelper
      include K3::Pages::PagesHelper
    end
  end
end
