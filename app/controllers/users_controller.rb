class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def edit
    @user = current_user
    @user.password_digest = nil
  end

  def create
    @user = User.create(user_params)
    if @user.save
      session[:slug] = @user.slug
      flash[:success] = 'You are registered and logged in'
      redirect_to profile_path
    else
      render :new
    end
  end

  def update
    @user = User.find_by(slug: params[:slug])

    render file: 'errors/not_found', status: 404 unless current_user == @user || current_admin?

    @user.update(user_params)
    
      if user_params.include?(:email)
       @user[:slug] = @user.slug_update(user_params[:email])
      end

    if @user.save
      session[:slug] = @user.slug
      flash[:success] = 'Profile data updated'
      if current_user == @user
        redirect_to profile_path
      elsif current_admin?
        redirect_to admin_user_path(@user)
      end
    else
      flash[:error] = 'Profile update failed'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :city, :state, :zip, :slug)
  end
end
