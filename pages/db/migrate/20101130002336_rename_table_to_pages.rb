class RenameTableToPages < ActiveRecord::Migration
  def self.up
    rename_table :k3_pages_pages, :pages
  end

  def self.down
    rename_table :pages, :k3_pages_pages
  end
end
