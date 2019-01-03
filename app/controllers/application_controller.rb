class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :current_merchant?, :current_admin?

  before_action :build_cart

  def current_user
    @current_user_lookup ||= User.find_by(slug: session[:slug]) if session[:slug]
  end

  def current_merchant?
    current_user && current_user.merchant?
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def build_cart
    @cart ||= Cart.new(session[:cart])
  end
end
