parent_class = ActiveRecord::Migration.respond_to?(:[]) ?
               ActiveRecord::Migration[4.2] :
               ActiveRecord::Migration
class AddArrayToArticles < parent_class
  def change
    add_column :articles, :some_array, :integer, array: true
  end
end
