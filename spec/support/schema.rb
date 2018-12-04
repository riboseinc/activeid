ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.string :title
    t.text :body
    t.column :some_array, :integer, array: true

    t.timestamps
  end

  create_table :uuid_articles, id: false do |t|
    t.uuid :id, primary_key: true
    t.string :title
    t.text :body
    t.uuid :another_uuid

    t.timestamps
  end
end
