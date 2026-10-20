require "rails_helper"

RSpec.describe "スポット", type: :request do
  describe "GET /spots" do
    it "未ログインでも一覧を表示できる" do
      spot = create(:spot, name: "一覧表示確認スポット")

      get spots_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("スポット一覧")
      expect(response.body).to include(spot.name)
    end

    it "都道府県でスポットを絞り込める" do
      kyoto_spot = create(:spot, name: "京都の観光地")
      osaka_spot = create(
        :spot,
        name: "大阪の観光地",
        prefecture: "大阪府",
        city: "大阪市"
      )

      get spots_path, params: { prefecture: "京都府" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(kyoto_spot.name)
      expect(response.body).not_to include(osaka_spot.name)
    end

    it "カテゴリーでスポットを絞り込める" do
      cafe = create(:spot, name: "検索確認カフェ", category: :cafe)
      sightseeing_spot = create(
        :spot,
        name: "検索確認観光地",
        category: :sightseeing
      )

      get spots_path, params: { category: "cafe" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(cafe.name)
      expect(response.body).not_to include(sightseeing_spot.name)
    end

    it "公開口コミの季節でスポットを絞り込める" do
      spring_spot = create(:spot, name: "春の検索対象スポット")
      winter_spot = create(:spot, name: "冬の検索対象スポット")

      create(:review, spot: spring_spot, season: :spring)
      create(:review, spot: winter_spot, season: :winter)

      get spots_path, params: { season: "spring" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(spring_spot.name)
      expect(response.body).not_to include(winter_spot.name)
    end

    it "公開口コミの同行者でスポットを絞り込める" do
      family_spot = create(:spot, name: "家族旅行の検索対象スポット")
      friends_spot = create(:spot, name: "友人旅行の検索対象スポット")

      create(:review, spot: family_spot, companion_type: :family)
      create(:review, spot: friends_spot, companion_type: :friends)

      get spots_path, params: { companion_type: "family" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(family_spot.name)
      expect(response.body).not_to include(friends_spot.name)
    end

    it "複数の条件すべてに一致するスポットだけを表示する" do
      matching_spot = create(:spot, name: "春の家族旅行スポット")
      spring_only_spot = create(:spot, name: "春だけ一致するスポット")
      family_only_spot = create(:spot, name: "家族だけ一致するスポット")

      create(
        :review,
        spot: matching_spot,
        season: :spring,
        companion_type: :family
      )
      create(
        :review,
        spot: spring_only_spot,
        season: :spring,
        companion_type: :friends
      )
      create(
        :review,
        spot: family_only_spot,
        season: :winter,
        companion_type: :family
      )

      get spots_path, params: {
        prefecture: "京都府",
        category: "sightseeing",
        season: "spring",
        companion_type: "family"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching_spot.name)
      expect(response.body).not_to include(spring_only_spot.name)
      expect(response.body).not_to include(family_only_spot.name)
    end

    it "条件に一致するスポットがない場合はメッセージを表示する" do
      spot = create(:spot, name: "京都限定の確認スポット")

      get spots_path, params: { prefecture: "大阪府" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("条件に一致するスポットはありません。")
      expect(response.body).not_to include(spot.name)
    end

    it "非公開口コミの季節だけが一致するスポットは表示しない" do
      published_spot = create(:spot, name: "公開口コミで春が一致するスポット")
      hidden_spot = create(:spot, name: "非公開口コミだけ春が一致するスポット")

      create(:review, spot: published_spot, season: :spring)
      create(
        :review,
        spot: hidden_spot,
        season: :spring,
        status: :hidden
      )
      create(:review, spot: hidden_spot, season: :winter)

      get spots_path, params: { season: "spring" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(published_spot.name)
      expect(response.body).not_to include(hidden_spot.name)
    end

    it "非公開口コミの同行者だけが一致するスポットは表示しない" do
      published_spot = create(:spot, name: "公開口コミで家族が一致するスポット")
      hidden_spot = create(:spot, name: "非公開口コミだけ家族が一致するスポット")

      create(:review, spot: published_spot, companion_type: :family)
      create(
        :review,
        spot: hidden_spot,
        companion_type: :family,
        status: :hidden
      )
      create(:review, spot: hidden_spot, companion_type: :friends)

      get spots_path, params: { companion_type: "family" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(published_spot.name)
      expect(response.body).not_to include(hidden_spot.name)
    end

    it "条件に一致する口コミが複数あってもスポットを重複表示しない" do
      spot = create(:spot, name: "重複表示確認スポット")
      create_list(
        :review,
        2,
        spot: spot,
        season: :spring,
        companion_type: :family
      )

      get spots_path, params: {
        season: "spring",
        companion_type: "family"
      }

      expect(response).to have_http_status(:ok)

      spot_names = response.parsed_body.css("article h2").map do |heading|
        heading.text.strip
      end

      expect(spot_names.count(spot.name)).to eq(1)
    end
  end

  describe "GET /spots/:id" do
    it "未ログインでも指定したスポットの詳細を表示できる" do
      spot = create(:spot, name: "詳細表示確認スポット")

      get spot_path(spot)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(spot.name)
    end
  end
end
