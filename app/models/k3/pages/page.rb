class K3::Pages::Page < ActiveRecord::Base
  validates :title, :presence => true
end
