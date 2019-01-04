class CartController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :require_default_user_or_visitor

  def index
    @items = @cart.items
  end

  def add_item
    add_item_to_cart(params[:slug])
    redirect_to items_path
  end

  def add_more_item
    add_item_to_cart(params[:slug])
    redirect_to cart_path
  end

  def remove_more_item
    item = Item.find_by(slug: params[:slug])
    @cart.subtract_item(item.id)
    flash[:success] = "You have removed 1 package of #{item.name} from your cart, new quantity is #{@cart.count_of(item.id)}"
    session[:cart] = @cart.contents
    redirect_to cart_path
  end

  def remove_all_of_item
    item = Item.find_by(slug: params[:slug])
    @cart.remove_all_of_item(item.id)
    flash[:success] = "You have removed all packages of #{item.name} from your cart"
    session[:cart] = @cart.contents
    redirect_to cart_path
  end

  def destroy
    session[:cart] = nil
    @cart = Cart.new(session[:cart])
    redirect_to cart_path
  end

  private

  def require_default_user_or_visitor
    render file: 'errors/not_found', status: 404 unless !current_user || (current_user && current_user.default?)
  end

  def add_item_to_cart(slug)
    item = Item.find_by(slug: slug)
    @cart.add_item(item.id)
    flash[:success] = "You have #{pluralize(@cart.count_of(item.id), 'package')} of #{item.name} in your cart"
    session[:cart] = @cart.contents
  end
end
