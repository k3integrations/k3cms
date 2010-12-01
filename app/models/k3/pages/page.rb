require 'active_record'

class K3::Pages::Page < ActiveRecord::Base
  validates :title, :presence => true

  def after_initialize
    set_default_title_or_url
  end

  def set_default_title_or_url
    self.title ||= url.gsub(%r[^/], '').humanize.gsub('-', ' ')
    self.url   ||= '/' + title.humanize.gsub(' ', '-').downcase
  end
end
