require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Profile Orders page', type: :feature do
  before :each do
    @user = create(:user)
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_2)

    yesterday = 1.day.ago

    @order = create(:completed_order, user: @user, created_at: yesterday)
    @order_2 = create(:order, user: @user, created_at: yesterday)

    @oi_1 = create(:order_item, order: @order_2, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
    @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)
  end

  context 'as a registered user' do

    it 'allows me to leave a rating for items I have purchased'do

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    visit profile_order_path(@order)

    within "#oitem-#{@oi_2.id}" do
      expect(page).to have_content("Fulfilled: Yes")
      expect(page).to have_link("Review Item")
    end

    click_on 'Review Item'
      expect(current_path).to eq(new_item_review_path(@oi_2.item_id))

      title = "title_1"
      description = "description_1"
      score = 5

      fill_in :review_title, with: title
      fill_in :review_description, with: description
      fill_in :review_score, with: score

      click_on 'Create Review'

      item = Item.find(@oi_2.item_id)

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("you have reviewed #{item.name}")

      click_on "My Reviews"

      review = Review.last

      within "#review-#{review.id}" do
        expect(page).to have_content(review.title)
        expect(page).to have_content(review.description)
        expect(page).to have_content(review.score)
        expect(page).to have_link("Edit Review")
        expect(page).to have_link("Disable Review")
        expect(page).to have_link("Delete Review")
      end
    end
    #Ratings will include a title, a description, and a rating from 1 to 5.

    describe 'i cannot rate an item I have canceled purchase of' do
    end

    describe 'I can only write one rating per item order' do
    end

    describe 'if I order th item again I can leave and other rating' do
    end

    describe 'I can disable a rating' do
    end

    describe 'has an average rating shown on the item show page' do
    end
  end
end

#navigate to a reviews
#index page from their profile page, and from there they can add, edit, show, or delete any review.

# Users will have the ability to leave ratings for items they have successfully purchased.
#
# Users cannot rate items from orders which have been canceled by the user.
#
# Users can write one rating per item per order. If the user orders an item (in any quantity) they can leave one rating.
#If they order the item again in a different order, the user can leave another rating.
#
# Build all CRUD functionality for users to add a rating through their order show page.
#
# Users can disable any rating they created.
#
# Disabled ratings should not factor into total counts of ratings, nor averages of ratings.
#
# Ratings will include a title, a description, and a rating from 1 to 5.
#
# Mod 2 Learning Goals reflected:
# Database relationships
# Rails development (including routing)
# Software Testing
# HTML/CSS styling and layout
