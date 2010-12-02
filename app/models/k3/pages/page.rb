require 'active_record'
require 'action_controller'

class K3::Pages::Page < ActiveRecord::Base
  validates :title, :presence => true

  class RouteDoesNotConflictWithRailsRoutesValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      begin
        if rails_route = Rails.application.routes.recognize_path(value)
          Rails.logger.debug "... The url of #{record.to_s} conflicts with #{rails_route.inspect}."
          record.errors[attribute] << ": The URL of this user-created page is the same as that of a built-in page. Please choose a different URL for your page."
        end
      rescue ActionController::RoutingError
        # This is actually the normal case
      end
    end
  end
  validates :url, :route_does_not_conflict_with_rails_routes => true

  after_initialize :set_default_title_or_url

  def set_default_title_or_url
    self.title ||= url.gsub(%r[^/], '').humanize.gsub('-', ' ') if url
    self.url   ||= '/' + title.humanize.gsub(' ', '-').downcase if title
  end

  def to_s
    title
  end

  def inspect
    "Page #{id} (#{title})"
  end
end
