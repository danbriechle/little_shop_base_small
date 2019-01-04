class Admin::ItemsController < Admin::BaseController
  def index
    @merchant = User.find_by(slug: params[:merchant_slug])
    @items = @merchant.items
    render '/dashboard/items/index'
  end

  def new
    @merchant = User.find_by(slug: params[:merchant_slug])
    @item = Item.new
    @form_path = [:admin, @merchant, @item]
    render "/dashboard/items/new"
  end

  def edit
    @merchant = User.find_by(slug: params[:merchant_slug])
    @item = Item.find_by(slug: params[:slug])
    @form_path = [:admin, @merchant, @item]
    render "/dashboard/items/edit"
  end

end
