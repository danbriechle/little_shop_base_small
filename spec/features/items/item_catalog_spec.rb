require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Item Catalog page', type: :feature do
  describe 'as any user' do
    it 'should show basic information about each item' do
      items = create_list(:item, 10)
      inactive_item_1 = create(:inactive_item)

      visit items_path

      items.each do |item|
        within "#item-#{item.id}" do
          expect(page).to have_content(item.name)
          expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
          expect(page).to have_content("Sold by: #{item.user.name}")
          expect(page).to have_content("Price: #{number_to_currency(item.price)}")
          expect(page).to have_content("In stock: #{item.inventory}")
        end
      end

      expect(page).to_not have_css("#item-#{inactive_item_1.id}")
      expect(page).to_not have_content(inactive_item_1.name)
      expect(page).to_not have_content("Sold by: #{inactive_item_1.user.name}")
    end
    it 'should show the top and bottom items by quantity popularity' do
      merchant = create(:merchant)
      items = create_list(:item, 6, user: merchant)
      user = create(:user)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: items[3], quantity: 7) # Name 4
      create(:fulfilled_order_item, order: order, item: items[1], quantity: 6) # Name 2
      create(:fulfilled_order_item, order: order, item: items[0], quantity: 5) # Name 1
      create(:fulfilled_order_item, order: order, item: items[2], quantity: 3) # Name 3
      create(:fulfilled_order_item, order: order, item: items[5], quantity: 2) # Name 6
      create(:fulfilled_order_item, order: order, item: items[4], quantity: 1) # Name 5

      visit items_path

      within '#statistics' do
        within '#popular-items' do
          popular = Item.popular_items(5)
          expect(page).to have_content("#{items[3].name}, total ordered: #{popular[0].total_ordered}")
          expect(page).to have_content("#{items[1].name}, total ordered: #{popular[1].total_ordered}")
          expect(page).to have_content("#{items[0].name}, total ordered: #{popular[2].total_ordered}")
          expect(page).to have_content("#{items[2].name}, total ordered: #{popular[3].total_ordered}")
          expect(page).to have_content("#{items[5].name}, total ordered: #{popular[4].total_ordered}")
        end
        within '#unpopular-items' do
          not_popular = Item.unpopular_items(5)
          expect(page).to have_content("#{items[4].name}, total ordered: #{not_popular[0].total_ordered}")
          expect(page).to have_content("#{items[5].name}, total ordered: #{not_popular[1].total_ordered}")
          expect(page).to have_content("#{items[2].name}, total ordered: #{not_popular[2].total_ordered}")
          expect(page).to have_content("#{items[0].name}, total ordered: #{not_popular[3].total_ordered}")
          expect(page).to have_content("#{items[1].name}, total ordered: #{not_popular[4].total_ordered}")
        end
      end
    end
  end
  describe 'as a registered user or visitor' do
  end
end
