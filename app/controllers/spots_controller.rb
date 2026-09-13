class SpotsController < ApplicationController
  def index
    @spots = Spot.all
  end

  def show
    @spot = Spot.find(params[:id])
    @current_user_review = @spot.reviews.find_by(user: current_user) if user_signed_in?
  end
end
