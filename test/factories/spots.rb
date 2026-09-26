FactoryBot.define do
  factory :spot do
    sequence(:name) { |n| "テストスポット#{n}" }
    prefecture { "京都府" }
    city { "京都市東山区" }
    sequence(:address) { |n| "テスト町#{n}-1" }
    official_url { "https://example.com" }
    category { :sightseeing }
  end
end
