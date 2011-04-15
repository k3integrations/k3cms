require 'cancan'

module K3cms
  module Pages
    class BaseController < ApplicationController
      # Needed for CanCan authorization
      include CanCan::ControllerAdditions

      def current_ability
        @current_ability ||= K3cms::Pages::Ability.new(k3cms_user)
      end

      rescue_from CanCan::AccessDenied do |exception|
        k3cms_authorization_required
      end

      helper K3cms::InlineEditor::InlineEditorHelper
      include K3cms::Pages::PagesHelper
    end
  end
end
