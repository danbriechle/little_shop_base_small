class Dashboard::OrdersController < Dashboard::BaseController
  def show
    @order = Order.find(params[:id])
    @items = @order.my_items(current_user)
  end

  def fulfill_item
    order = Order.find(params[:order_id])
    item = Item.find_by(slug: params[:slug])
    oi = order.order_items.find_by(item_id: item.id)
    if oi
      oi.fulfilled = true
      oi.save
      item.inventory -= oi.quantity
      item.save
    end
    if order.order_items.where(fulfilled: false).empty?
      order.status = :completed
      order.save
    end
    redirect_to dashboard_order_path(order)
  end
end
