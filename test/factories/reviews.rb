FactoryBot.define do
  factory :review do
    association :user
    association :spot
    rating { 5 }
    body { "とても素敵なスポットでした。" }
    good_point { "景色がきれいでした。" }
    bad_point { "休日は少し混雑していました。" }
    season { :spring }
    status { :published }
    purpose { :sightseeing }
    companion_type { :friends }
  end
end
