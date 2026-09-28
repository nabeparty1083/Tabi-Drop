class SpotsController < ApplicationController
  def index
    @prefectures = Spot.distinct.order(:prefecture).pluck(:prefecture)
    @spots = SpotSearch.new(params).call
  end

  def show
    @spot = Spot.find(params[:id])
    @reviews = @spot.reviews.published.includes(:user).order(created_at: :desc)

  if user_signed_in?
    @current_user_review = @spot.reviews.find_by(user: current_user)
    @favorite = current_user.favorites.find_by(spot: @spot)
  end
 end
end
