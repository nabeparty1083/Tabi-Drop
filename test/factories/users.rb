FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "factory_user_#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    name { "テストユーザー" }
    residence { "京都府" }
    bio { "旅行が好きです。" }
  end
end
