class RenameUserToAuthor < ActiveRecord::Migration
  def self.up
    change_table :k3_pages do |t|
      t.rename :user_id, :author_id
    end
  end

  def self.down
    change_table :k3_pages do |t|
      t.rename :author_id, :user_id
    end
  end
end
