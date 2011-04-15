class RenameToK3cmsPages < ActiveRecord::Migration
  def self.up
    rename_table :k3_pages, :k3cms_pages
  end

  def self.down
    rename_table :k3cms_pages, :k3_pages
  end
end
