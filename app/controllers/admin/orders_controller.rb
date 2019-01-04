class Admin::OrdersController < Admin::BaseController
  def index
    @user = User.find_by(slug: params[:user_slug])
    @orders = @user.orders
    render '/profile/orders/index'
  end

  def show
    @user = User.find_by(slug: params[:user_slug])
    @order = Order.find(params[:id])
    render '/profile/orders/show'
  end
end
