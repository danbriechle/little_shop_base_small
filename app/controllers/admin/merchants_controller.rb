class Admin::MerchantsController < Admin::BaseController
  def show
    @merchant = User.find_by(slug: params[:slug])
    if @merchant.default?
      redirect_to admin_user_path(@merchant)
    else
      @orders = @merchant.my_pending_orders
      @orders = @merchant.my_pending_orders
      @top_5_items = @merchant.top_items_by_quantity(5)
      @qsp = @merchant.quantity_sold_percentage
      @top_3_states = @merchant.top_3_states
      @top_3_cities = @merchant.top_3_cities
      @most_ordering_user = @merchant.most_ordering_user
      @most_items_user = @merchant.most_items_user
      @most_items_user = @merchant.most_items_user
      @top_3_revenue_users = @merchant.top_3_revenue_users
      render :'merchants/show'
    end
  end

  def enable
    set_user_active(true)
  end

  def disable
    set_user_active(false)
  end

  def downgrade
    set_user_role(User.find_by(slug: params[:merchant_slug]), :default)
    redirect_to merchants_path
  end

  private

  def set_user_active(state)
    user = User.find_by(slug: params[:merchant_slug])
    user.active = state
    user.save
    redirect_to merchants_path
  end
end
