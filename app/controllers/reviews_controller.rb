class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_spot
  before_action :set_review, only: %i[edit update]

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

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to @spot, notice: "口コミを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_spot
    @spot = Spot.find(params[:spot_id])
  end

  def set_review
    @review = current_user.reviews.find_by!(
      id: params[:id],
      spot: @spot
    )
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
