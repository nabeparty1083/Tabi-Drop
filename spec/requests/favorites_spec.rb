require "rails_helper"

RSpec.describe "お気に入り", type: :request do
  let(:user) { create(:user) }

  describe "GET /favorites" do
    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "自分のお気に入りだけを表示する" do
        my_spot = create(:spot, name: "自分のお気に入りスポット")
        other_spot = create(:spot, name: "他の人のお気に入りスポット")
        other_user = create(:user)

        Favorite.create!(user: user, spot: my_spot)
        Favorite.create!(user: other_user, spot: other_spot)

        get favorites_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("お気に入り一覧")
        expect(response.body).to include(my_spot.name)
        expect(response.body).not_to include(other_spot.name)
      end

      it "お気に入りがない場合は案内を表示する" do
        get favorites_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(
          "お気に入りに登録したスポットはありません。"
        )
        expect(response.body).to include("スポットを探す")
      end
    end

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトする" do
        get favorites_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
    describe "POST /spots/:spot_id/favorite" do
    let(:spot) { create(:spot) }

    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "自分のお気に入りにスポットを登録できる" do
        expect {
          post spot_favorite_path(spot)
        }.to change(Favorite, :count).by(1)

        expect(
          Favorite.exists?(user_id: user.id, spot_id: spot.id)
        ).to be true
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(spot_path(spot))
        expect(flash[:notice]).to eq("お気に入りに登録しました。")
      end

      it "同じスポットを重複して登録しない" do
        Favorite.create!(user: user, spot: spot)

        expect {
          post spot_favorite_path(spot)
        }.not_to change(Favorite, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(spot_path(spot))
      end
    end

    context "ログインしていない場合" do
      it "登録せずにログイン画面へリダイレクトする" do
        expect {
          post spot_favorite_path(spot)
        }.not_to change(Favorite, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
    describe "DELETE /spots/:spot_id/favorite" do
    let(:spot) { create(:spot) }

    context "ログインしている場合" do
      before do
        sign_in user
        Favorite.create!(user: user, spot: spot)
      end

      it "自分のお気に入りだけを解除し、戻り先がなければスポット詳細へ移動する" do
        other_user = create(:user)
        other_favorite = Favorite.create!(user: other_user, spot: spot)

        expect {
          delete spot_favorite_path(spot)
        }.to change(Favorite, :count).by(-1)

        expect(
          Favorite.exists?(user_id: user.id, spot_id: spot.id)
        ).to be false
        expect(Favorite.exists?(other_favorite.id)).to be true
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(spot_path(spot))
        expect(flash[:notice]).to eq("お気に入りを解除しました。")
      end

      it "戻り先がある場合は元のページへリダイレクトする" do
        expect {
          delete spot_favorite_path(spot),
                 headers: { "HTTP_REFERER" => favorites_url }
        }.to change(Favorite, :count).by(-1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(favorites_url)
      end
    end

    context "ログインしていない場合" do
      it "解除せずにログイン画面へリダイレクトする" do
        favorite = Favorite.create!(user: user, spot: spot)

        expect {
          delete spot_favorite_path(spot)
        }.not_to change(Favorite, :count)

        expect(Favorite.exists?(favorite.id)).to be true
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
