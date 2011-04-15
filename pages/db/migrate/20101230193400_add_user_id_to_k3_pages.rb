class AddUserIdToK3Pages < ActiveRecord::Migration
  def self.up
    add_column :k3_pages, :user_id, :integer
  end

  def self.down
    remove_column :k3_pages, :user_id, :integer
  end
end
