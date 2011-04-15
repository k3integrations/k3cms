require 'active_record'
require File.expand_path('../../../../lib/route_set_decorator', __FILE__)

module K3
  class Page < ActiveRecord::Base
    set_table_name 'k3_pages'

    belongs_to :author, :class_name => 'User'

    #normalize_attributes :title, :body, :url, :with => [:strip, :blank]

    validates :title, :presence => true

    class RouteDoesNotConflictWithRailsRoutesValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        begin
          if value and rails_route = Rails.application.routes.recognize_route_from_path(value)
            # Ignore catch-all routes, which is defined here to mean those that match with a *
            # For example, when integrated with Spree: They have this catch-all route:
            #   match '/*path' => 'content#show'
            # which is represented with this object:
            #   #<Rack::Mount::Route @app=#<ActionDispatch::Routing::RouteSet::Dispatcher:0x00000004b057d0 @defaults={:controller=>"content", :action=>"show"}, @glob_param=nil, @controllers={}>
            #   @conditions={:path_info=>/\A\/(?<path>.+)(?:\.(?<format>[^\/.?]+))?\Z/} @defaults={:controller=>"content", :action=>"show"} @name=nil>
            unless rails_route.conditions[:path_info].to_s =~ /\(\?<\w+>\.\+\)/
              Rails.logger.debug "... The url of #{record.to_s} conflicts with #{rails_route.inspect}."
              record.errors[attribute] << ": The URL of this user-created page is the same as that of a built-in page. Please choose a different URL for your page."
            end
          end
        rescue ActionController::RoutingError
          # This is actually the normal case
        end
      end
    end
    validates :url, :route_does_not_conflict_with_rails_routes => true,
                    :uniqueness => true, :allow_nil => true

    after_initialize :set_default_body
    def set_default_body
      self.body = '<p></p>' if self.attributes['body'].nil?
    end

    after_initialize :set_default_title_or_url
    def set_default_title_or_url
      self.title = url.gsub(%r[^/], '').humanize.gsub('-', ' ') if self.attributes['url']   && self.attributes['title'].nil?
      self.url   = '/' + title.humanize.gsub(' ', '-').downcase if self.attributes['title'] && self.attributes['url'].nil?
    end

    def to_s
      title
    end

    def inspect
      "Page #{id} (#{title})"
    end
  end
end
