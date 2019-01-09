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
      click_on 'Review Item'
    end


      expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

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
    it 'I cannot leave a review with incorect info' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_order_path(@order)

      within "#oitem-#{@oi_2.id}" do
        expect(page).to have_content("Fulfilled: Yes")
        expect(page).to have_link("Review Item")
        click_on 'Review Item'
      end


      expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

      title = "title_1"
      # description = "description_1"
      score = 2

      fill_in :review_title, with: title
      # fill_in :review_description, with: description
      fill_in :review_score, with: score

      click_on 'Create Review'

      expect(page).to have_content("Required Fields Missing or Incorrect")

    end

    it 'I cannot leave a review with wrong score info' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_order_path(@order)

      within "#oitem-#{@oi_2.id}" do
        expect(page).to have_content("Fulfilled: Yes")
        expect(page).to have_link("Review Item")
        click_on 'Review Item'
      end


      expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

      title = "title_1"
      description = "description_1"
      score = 2000000

      fill_in :review_title, with: title
      fill_in :review_description, with: description
      fill_in :review_score, with: score

      click_on 'Create Review'

      expect(page).to have_content("Required Fields Missing or Incorrect")

    end

    it 'I cannot rate an item I have canceled purchase of' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_order_path(@order_2)

      within "#oitem-#{@oi_1.id}" do
        expect(page).to have_content("Fulfilled: No")
        expect(page).to_not have_link("Review Item")
      end

      click_on "Cancel Order"
      expect(page).to_not have_link("Review Item")
    end

    it 'I can only review one item per order' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      yesterday = 1.day.ago

      @oi_4 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago, reviewed: true)

      visit profile_order_path(@order)

      within "#oitem-#{@oi_2.id}" do
        expect(page).to have_content("Fulfilled: Yes")
        expect(page).to_not have_link("Review Item")
        expect(page).to have_content("You have already reviewed this item")
      end
    end

    it 'I updates reviews when added' do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_order_path(@order)

      within "#oitem-#{@oi_2.id}" do
        expect(page).to have_content("Fulfilled: Yes")
        expect(page).to have_link("Review Item")
        click_on 'Review Item'
      end



        expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

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

        click_on "My Orders"

        click_on "Order ID #{@order.id}"

        within "#oitem-#{@oi_2.id}" do
          expect(page).to have_content("Fulfilled: Yes")
          expect(page).to_not have_link("Review Item")
        end
    end

    it 'if I order the item again I can leave another rating' do
      yesterday = 1.day.ago
      @order_4 = create(:completed_order, user: @user, created_at: yesterday)
      @oi_4 = create(:fulfilled_order_item, order: @order_4, item: @item_2, price: 5, quantity: 1, created_at: yesterday, updated_at: 4.hours.ago)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)


      visit profile_order_path(@order.id)
      within "#oitem-#{@oi_2.id}" do
        expect(page).to have_content("Fulfilled: Yes")
        expect(page).to have_link("Review Item")
        click_on 'Review Item'
      end

        expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

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

        visit profile_order_path(@order_4.id)
        within "#oitem-#{@oi_4.id}" do
          expect(page).to have_content("Fulfilled: Yes")
          expect(page).to have_link("Review Item")
          click_on 'Review Item'
        end


          expect(current_path).to eq(profile_order_new_review_path(@order_4, @oi_4.id))

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
    end

    it 'I can delete a review' do

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    visit profile_order_path(@order)

    within "#oitem-#{@oi_2.id}" do
      expect(page).to have_content("Fulfilled: Yes")
      expect(page).to have_link("Review Item")
      click_on 'Review Item'
    end


      expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

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
        click_on "Delete Review"
      end

      expect(current_path).to eq(profile_path)

      click_on "My Reviews"

      expect(page).to_not have_content(review.title)
      expect(page).to_not have_content(review.description)
      expect(page).to_not have_content(review.score)

    end

    it 'I can edit a review' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    visit profile_order_path(@order)

    within "#oitem-#{@oi_2.id}" do
      expect(page).to have_content("Fulfilled: Yes")
      expect(page).to have_link("Review Item")
      click_on 'Review Item'
    end


      expect(current_path).to eq(profile_order_new_review_path(@order, @oi_2.id))

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

      click_on "Edit Review"

      new_title = "new_title_1"
      new_description = "new_description_1"
      new_score = 3

      fill_in :review_title, with: new_title
      fill_in :review_description, with: new_description
      fill_in :review_score, with: new_score

      click_on 'Update Review'

      item = Item.find(@oi_2.item_id)

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("you updated your review of #{item.name}")

      click_on "My Reviews"

      new_review = Review.last

      within "#review-#{new_review.id}" do
        expect(page).to have_content(new_title)
        expect(page).to have_content(new_description)
        expect(page).to have_content(new_score)
        expect(page).to have_link("Edit Review")
        expect(page).to have_link("Disable Review")
        expect(page).to have_link("Delete Review")
      end
    end

    it 'I cant edit a review with wrong info' do
    end

    describe 'I can disable a rating' do
    end


    describe 'has an average rating shown on the item show page' do
    end

    describe 'has the total count of ratings on the Items show page' do
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
