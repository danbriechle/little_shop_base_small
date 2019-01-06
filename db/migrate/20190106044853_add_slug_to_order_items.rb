class AddSlugToOrderItems < ActiveRecord::Migration[5.1]
  def change
    add_column :order_items, :slug, :string
    add_index :order_items, :slug
  end
end
