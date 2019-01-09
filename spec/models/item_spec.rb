require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        expect(Item.popular_items(3)).to eq([@items[3], @items[1], @items[0]])
      end
      it '.unpopular_items' do
        expect(Item.unpopular_items(3)).to eq([@items[4], @items[5], @items[2]])
      end
    end
  end

  describe 'instance methods' do
    it '.avg_fulfillment_time' do
      item = create(:item)
      merchant = item.user
      user = create(:user)
      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item, created_at: 4.days.ago, updated_at: 1.days.ago)
      create(:fulfilled_order_item, order: order, item: item, created_at: 1.hour.ago, updated_at: 30.minutes.ago)

      expect(item.avg_fulfillment_time).to include("1 day 12:15:00")
    end

    it '.ever_ordered?' do
      item_1 = create(:item)
      item_2 = create(:item)
      order = create(:completed_order)
      create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

      expect(item_1.ever_ordered?).to eq(true)
      expect(item_2.ever_ordered?).to eq(false)
    end

    it '.average_score' do
      user_1 = create(:user)

      merchant_1 = create(:merchant)

      item_1 = create(:item, user: merchant_1)

      order_1 = create(:completed_order, user: user_1)

      oi_1 = create(:fulfilled_order_item, item: item_1, order: order_1, quantity: 1, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

      oi_2 = create(:fulfilled_order_item, item: item_1, order: order_1, quantity: 1, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

      review = user_1.reviews.create!(title: "Text", description: "text", score: 4 , order_item: oi_1 )

      review = user_1.reviews.create!(title: "Text", description: "text", score: 2 , order_item: oi_2 )


      expect(item_1.average_score).to eq(3)
    end
  end

  describe 'slug methods' do
    it '.generate_slug' do
      item_1 = create(:item, name: "best_item ever?")
      item_2 = create(:item, name: "best item@ever!")

      expect(item_1.slug.include?("best-item-ever")).to be true
      expect(item_2.slug.include?("best-item-ever")).to be true

      expect(item_1.slug).to_not eq(item_2.slug)
    end
  end
end
