class Admin::UsersController < Admin::BaseController
  def index
    @users = User.where(role: :default)
  end

  def show
    @user = User.find_by(slug: params[:slug])
    if @user.merchant?
      redirect_to admin_merchant_path(@user)
    else
      render :'profile/index'
    end
  end

  def edit
    @user = User.find_by(slug: params[:slug])
    @user.password_digest = nil
    render :'users/edit'
  end

  def enable
    set_user_active(true)
  end

  def disable
    set_user_active(false)
  end

  def upgrade
    set_user_role(User.find_by(slug: params[:user_slug]), :merchant)
    redirect_to admin_users_path
  end

  private

  def set_user_active(state)
    user = User.find_by(slug: params[:user_slug])
    user.active = state
    user.save
    redirect_to admin_users_path
  end
end
