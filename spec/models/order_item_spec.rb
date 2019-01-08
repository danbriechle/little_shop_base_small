require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'instance methods' do
    it '.item_reviewed?' do
    merchant = create(:merchant)
    item_1 = create(:item, user: merchant)
    order = create(:order)
    oi_1 = create(:fulfilled_order_item, order: order, item: item_1, price: 345.67, quantity: 397, reviewed: false)
    oi_2 = create(:fulfilled_order_item, order: order, item: item_1, price: 345.67, quantity: 397, reviewed: true)
    expect(oi_1.order_item_reviewed?).to eq(false)
    expect(oi_2.order_item_reviewed?).to eq(true)
    end
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end

    it '.generate_slug' do
      oi = create(:order_item, quantity: 5, price: 3)

      item = Item.find(oi.item_id)

      expect(item.slug).to eq(oi.slug)
    end
  end
end
