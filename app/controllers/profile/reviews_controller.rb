class Profile::ReviewsController < ApplicationController

  def index
    @reviews = Review.where(user_id: current_user.id)
  end

  def edit
    @review = Review.find(params[:id])
    @order_item = OrderItem.find(@review.order_item_id)
    @order = Order.find(@order_item.order_id)
    @form_path = [:profile, @order, @order_item, @review]
  end

  def new
    @review = Review.new
    @order = Order.find(params[:order_id])
    @order_item = OrderItem.find(params[:id])
    @form_path = [:profile, @order, @order_item, @review]
  end

  def create
    @user = current_user
    @order_item = OrderItem.find(params[:id])
    @item = Item.find(@order_item.item_id)
    hash = review_params
    hash[:order_item_id] = @order_item.id
    @review = @user.reviews.create(hash)


    if @review.save
      @order_item.update(reviewed: true)
      flash[:notice] = "you have reviewed #{@item.name}"
      redirect_to profile_path
    else
      flash[:error] = "Required Fields Missing or Incorrect"
      redirect_to profile_order_new_review_path(@order_item.order_id, @order_item.id)
    end
  end

  def destroy
    review = Review.find(params[:id])
    review.destroy
    redirect_to profile_path
  end

  def update
    @review = Review.find(params[:format])
    @user = current_user
    @order_item = OrderItem.find(params[:id])
    @item = Item.find(@order_item.item_id)
    hash = review_params
    hash[:order_item_id] = @order_item.id

    if @review.update(review_params)
      @order_item.update(reviewed: true)
      flash[:notice] = "you updated your review of #{@item.name}"
      redirect_to profile_path
    else
      flash[:error] = "Required Fields Missing or Incorrect"
      redirect_to profile_order_edit_review_path(@order_item.order_id, @order_item.id)
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :score)
  end

end
