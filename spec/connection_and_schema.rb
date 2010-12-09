require 'active_record'

ActiveRecord::Base.establish_connection({
  :database => ":memory:",
  :adapter  => 'sqlite3',
  :timeout  => 500
})

ActiveRecord::Schema.define do
  # TODO: Don't duplicate the migrations. Invoke them directly the same way rake db:migrate does it.
  create_table :k3_pages do |t|
    t.string :title
    t.string :url
    t.text :body

    t.timestamps
  end
end
