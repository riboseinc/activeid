ActiveRecord::Schema.define do
  create_table :articles, force: true do |t|
    t.string :title
    t.text :body
    t.column :some_array, :integer, array: true

    t.timestamps
  end

  create_table :binary_uuid_articles, id: false, force: true do |t|
    t.binary :id, limit: 16, primary_key: true
    t.string :title
    t.text :body
    t.binary :another_uuid, limit: 16

    t.timestamps
  end

  create_table :string_uuid_articles, id: false, force: true do |t|
    t.string :id, limit: 36, primary_key: true
    t.string :title
    t.text :body
    t.string :another_uuid, limit: 36

    t.timestamps
  end

  if ENV["DB"] == "postgresql"
    create_table :native_uuid_articles, id: false, force: true do |t|
      t.uuid :id, primary_key: true
      t.string :title
      t.text :body
      t.uuid :another_uuid

      t.timestamps
    end
  end
end
