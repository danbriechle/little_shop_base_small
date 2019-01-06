class ReviewsController < ApplicationController

  def new
    @review = Review.new
    @item = Item.find(params[:item_slug])
  end

  def create
    @user = current_user
    @item = Item.find_by(slug: params[:item_slug])

    hash = review_params
    hash[:user_id] = @user.id

    @review = @item.reviews.create(hash)

    if @review.save
      flash[:notice] = "you have reviewed #{@item.name}"
      redirect_to profile_path
    else
      render '/new'
    end
  end



  private

  def review_params
    params.require(:review).permit(:title, :description, :score)
  end

end
