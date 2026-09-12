class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_spot

  def new
    @review = Review.new(user: current_user, spot: @spot)
  end

  def create
    @review = Review.new(review_params)
    @review.user = current_user
    @review.spot = @spot

    if @review.save
      redirect_to @spot, notice: "口コミを投稿しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_spot
    @spot = Spot.find(params[:spot_id])
  end

  def review_params
    params.require(:review).permit(
      :rating,
      :body,
      :good_point,
      :bad_point,
      :season,
      :purpose,
      :companion_type,
      :image
    )
  end
end
