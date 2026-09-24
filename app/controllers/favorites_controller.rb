class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_spot, only: %i[create destroy]

  def index
    @favorites = current_user.favorites.includes(:spot).order(created_at: :desc)
  end

  def create
    current_user.favorites.find_or_create_by!(spot: @spot)

    redirect_to @spot,
                notice: "お気に入りに登録しました。",
                status: :see_other
  end

  def destroy
    favorite = current_user.favorites.find_by!(spot: @spot)
    favorite.destroy!

    redirect_back fallback_location: @spot,
                  notice: "お気に入りを解除しました。",
                  status: :see_other
  end

  private

  def set_spot
    @spot = Spot.find(params[:spot_id])
  end
end
