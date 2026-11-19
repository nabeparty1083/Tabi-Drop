# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
spots = [
  {
    name: "京都府立植物園",
    prefecture: "京都府",
    city: "京都市左京区",
    address: "京都府京都市左京区下鴨半木町",
    category: :sightseeing,
    official_url: "https://www.kyotobotanicalgardens.jp/"
  },
  {
    name: "京都鉄道博物館",
    prefecture: "京都府",
    city: "京都市下京区",
    address: "京都府京都市下京区観喜寺町",
    category: :sightseeing,
    official_url: "https://www.kyotorailwaymuseum.jp/"
  },
  {
    name: "梅小路公園",
    prefecture: "京都府",
    city: "京都市下京区",
    address: "京都府京都市下京区観喜寺町56-3",
    category: :sightseeing,
    official_url: "https://www.kyoto-ga.jp/umekouji/"
  },
  {
    name: "平等院",
    prefecture: "京都府",
    city: "宇治市",
    address: "京都府宇治市宇治蓮華116",
    category: :sightseeing,
    official_url: "https://www.byodoin.or.jp/"
  }
]

Spot.transaction do
  spots.each do |attributes|
    Spot.find_or_create_by!(
      name: attributes.fetch(:name),
      address: attributes.fetch(:address)
    ) do |spot|
      spot.assign_attributes(attributes)
    end
  end
end
