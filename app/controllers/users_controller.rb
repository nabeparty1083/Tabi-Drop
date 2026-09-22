class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update]
  before_action :set_user, only: %i[show edit update]
  before_action :authorize_user!, only: %i[edit update]

  def show
    @reviews = @user.reviews
                    .published
                    .includes(:spot)
                    .order(created_at: :desc)
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user!
    return if @user == current_user

    redirect_to @user, alert: "自分のプロフィールのみ編集できます"
  end

  def user_params
    params.require(:user).permit(:name, :residence, :bio)
  end
end
