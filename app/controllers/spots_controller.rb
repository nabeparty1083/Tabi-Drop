class SpotsController < ApplicationController
  def index
    @prefectures = Spot.distinct.order(:prefecture).pluck(:prefecture)
    @spots = SpotSearch.new(params).call
  end

  def show
    @spot = Spot.find(params[:id])
    @reviews = @spot.reviews.published

    if Review.seasons.key?(params[:season])
      @reviews = @reviews.where(season: params[:season])
    end

    if Review.companion_types.key?(params[:companion_type])
      @reviews = @reviews.where(companion_type: params[:companion_type])
    end

    @reviews = @reviews.includes(:user).order(created_at: :desc)

    if user_signed_in?
      @current_user_review = @spot.reviews.find_by(user: current_user)
      @favorite = current_user.favorites.find_by(spot: @spot)
    end
  end
end
