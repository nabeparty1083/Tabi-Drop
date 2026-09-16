class SpotsController < ApplicationController
  def index
    @prefectures = Spot.distinct.order(:prefecture).pluck(:prefecture)
    @spots = Spot.all

    if params[:prefecture].present?
      @spots = @spots.where(prefecture: params[:prefecture])
    end

    if Spot.categories.key?(params[:category])
      @spots = @spots.where(category: params[:category])
    end

    if Review.seasons.key?(params[:season])
      @spots = @spots.joins(:reviews)
                     .where(reviews: { season: params[:season], status: :published })
    end

    if Review.companion_types.key?(params[:companion_type])
      @spots = @spots.joins(:reviews)
                     .where(reviews: {
                       companion_type: params[:companion_type],
                       status: :published
                     })
    end

    @spots = @spots.distinct
  end

  def show
  @spot = Spot.find(params[:id])

  if user_signed_in?
    @current_user_review = @spot.reviews.find_by(user: current_user)
    @favorite = current_user.favorites.find_by(spot: @spot)
  end
end
end
