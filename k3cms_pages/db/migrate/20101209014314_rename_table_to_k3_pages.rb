class RenameTableToK3Pages < ActiveRecord::Migration
  def self.up
    rename_table :pages, :k3_pages
  end

  def self.down
    rename_table :k3_pages, :pages
  end
end
