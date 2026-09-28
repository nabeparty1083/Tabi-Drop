class SpotSearch
  def initialize(params)
    @params = params
    @spots = Spot.all
  end

  def call
    filter_by_prefecture
    filter_by_category
    filter_by_season
    filter_by_companion_type

    @spots.distinct
  end

  private

  attr_reader :params

  def filter_by_prefecture
    return unless params[:prefecture].present?

    @spots = @spots.where(prefecture: params[:prefecture])
  end

  def filter_by_category
    return unless Spot.categories.key?(params[:category])

    @spots = @spots.where(category: params[:category])
  end

  def filter_by_season
    return unless Review.seasons.key?(params[:season])

    @spots = @spots.joins(:reviews)
                   .where(reviews: {
                     season: params[:season],
                     status: :published
                   })
  end

  def filter_by_companion_type
    return unless Review.companion_types.key?(params[:companion_type])

    @spots = @spots.joins(:reviews)
                   .where(reviews: {
                     companion_type: params[:companion_type],
                     status: :published
                   })
  end
end
