class AddReviewedToOrderItems < ActiveRecord::Migration[5.1]
  def change
    add_column :order_items, :reviewed, :boolean, default: false
  end
end
