parent_class = ActiveRecord::Migration.respond_to?(:[]) ?
               ActiveRecord::Migration[4.2] :
               ActiveRecord::Migration
class CreateArticles < parent_class
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
