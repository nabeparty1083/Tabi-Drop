class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @reviews = @user.reviews
                    .published
                    .includes(:spot)
                    .order(created_at: :desc)
  end
end
