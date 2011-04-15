class CreateK3PagesPages < ActiveRecord::Migration
  def self.up
    create_table :k3_pages_pages do |t|
      t.string :title
      t.string :url
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :k3_pages_pages
  end
end
