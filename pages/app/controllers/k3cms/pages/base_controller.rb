module K3cms
  module Pages
    class BaseController < ApplicationController

      include CanCan::ControllerAdditions
      helper K3cms::InlineEditor::InlineEditorHelper
      include K3cms::Pages::PagesHelper

      def current_ability
        @current_ability ||= K3cms::Pages::Ability.new(k3cms_user)
      end

      rescue_from CanCan::AccessDenied do |exception|
        k3cms_authorization_required(exception)
      end

    end
  end
end
