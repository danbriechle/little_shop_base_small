class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item
  before_create :generate_slug

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def order_item_reviewed?
    reviewed
  end

  private

  def generate_slug
    self.slug = item.slug
  end

end
