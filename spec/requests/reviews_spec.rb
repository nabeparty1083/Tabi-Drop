require "rails_helper"

RSpec.describe "口コミ", type: :request do
  let(:user) { create(:user) }
  let!(:spot) { create(:spot) }

  let(:valid_attributes) do
    {
      rating: 5,
      body: "景色がきれいで、ゆっくり楽しめました。",
      good_point: "朝は人が少なくて散策しやすい",
      bad_point: "駅から少し歩く",
      season: "spring",
      purpose: "sightseeing",
      companion_type: "friends"
    }
  end

  describe "POST /spots/:spot_id/reviews" do
    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "正しい入力で口コミを投稿できる" do
        expect {
          post spot_reviews_path(spot),
               params: { review: valid_attributes }
        }.to change(Review, :count).by(1)

        expect(response).to redirect_to(spot_path(spot))

        created_review = user.reviews.find_by!(spot: spot)
        expect(created_review).to have_attributes(valid_attributes)
      end

      it "本文が空の場合は保存されず422を返す" do
        invalid_attributes = valid_attributes.merge(body: "")

        expect {
          post spot_reviews_path(spot),
               params: { review: invalid_attributes }
        }.not_to change(Review, :count)

        expect(response).to have_http_status(422)
      end

      it "評価が範囲外の場合は保存されず422を返す" do
        invalid_attributes = valid_attributes.merge(rating: 6)

        expect {
          post spot_reviews_path(spot),
               params: { review: invalid_attributes }
        }.not_to change(Review, :count)

        expect(response).to have_http_status(422)
      end

      it "同じスポットに投稿済みの場合は保存されず422を返す" do
        create(:review, user: user, spot: spot)

        expect {
          post spot_reviews_path(spot),
               params: { review: valid_attributes }
        }.not_to change(Review, :count)

        expect(response).to have_http_status(422)
      end
    end

    context "未ログインの場合" do
      it "保存されずログイン画面へ移動する" do
        expect {
          post spot_reviews_path(spot),
               params: { review: valid_attributes }
        }.not_to change(Review, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /spots/:spot_id/reviews/:id" do
    let!(:review) do
      create(
        :review,
        user: user,
        spot: spot,
        body: "更新前の口コミ",
        rating: 3
      )
    end

    let(:updated_attributes) do
      {
        body: "更新後の口コミ",
        rating: 4
      }
    end

    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "本人の場合は口コミを更新できる" do
        patch spot_review_path(spot, review),
              params: { review: updated_attributes }

        expect(response).to redirect_to(spot_path(spot))
        expect(review.reload).to have_attributes(updated_attributes)
      end

      it "他人の場合は更新されず404を返す" do
        other_user = create(:user)
        sign_in other_user

        expect {
          patch spot_review_path(spot, review),
                params: { review: updated_attributes }
        }.not_to change { review.reload.attributes }

        expect(response).to have_http_status(:not_found)
      end

      it "本文が空の場合は更新されず422を返す" do
        invalid_attributes = updated_attributes.merge(body: "")

        expect {
          patch spot_review_path(spot, review),
                params: { review: invalid_attributes }
        }.not_to change { review.reload.attributes }

        expect(response).to have_http_status(422)
      end

      it "評価が範囲外の場合は更新されず422を返す" do
        invalid_attributes = updated_attributes.merge(rating: 6)

        expect {
          patch spot_review_path(spot, review),
                params: { review: invalid_attributes }
        }.not_to change { review.reload.attributes }

        expect(response).to have_http_status(422)
      end
    end

    context "未ログインの場合" do
      it "更新されずログイン画面へ移動する" do
        expect {
          patch spot_review_path(spot, review),
                params: { review: updated_attributes }
        }.not_to change { review.reload.attributes }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

    describe "DELETE /spots/:spot_id/reviews/:id" do
    let!(:review) { create(:review, user: user, spot: spot) }

    it "本人の場合は口コミを削除できる" do
      sign_in user

      expect {
        delete spot_review_path(spot, review)
      }.to change(Review, :count).by(-1)

      expect(response).to redirect_to(spot_path(spot))
      expect(Review.exists?(review.id)).to be false
    end

    it "他人の場合は削除されず404を返す" do
      other_user = create(:user)
      sign_in other_user

      expect {
        delete spot_review_path(spot, review)
      }.not_to change(Review, :count)

      expect(response).to have_http_status(:not_found)
      expect(Review.exists?(review.id)).to be true
    end

    it "未ログインの場合は削除されずログイン画面へ移動する" do
      expect {
        delete spot_review_path(spot, review)
      }.not_to change(Review, :count)

      expect(response).to redirect_to(new_user_session_path)
      expect(Review.exists?(review.id)).to be true
    end
  end
    describe "GET /spots/:spot_id/reviews/new" do
    it "ログインしている場合は投稿画面を表示できる" do
      sign_in user

      get new_spot_review_path(spot)

      expect(response).to have_http_status(:ok)
    end

    it "未ログインの場合はログイン画面へ移動する" do
      get new_spot_review_path(spot)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /spots/:spot_id/reviews/:id/edit" do
    let!(:review) do
      create(:review, user: user, spot: spot, body: "編集する口コミ")
    end

    it "本人の場合は編集画面に口コミの内容を表示できる" do
      sign_in user

      get edit_spot_review_path(spot, review)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(review.body)
    end

    it "他人の場合は404を返す" do
      other_user = create(:user)
      sign_in other_user

      get edit_spot_review_path(spot, review)

      expect(response).to have_http_status(:not_found)
    end

    it "未ログインの場合はログイン画面へ移動する" do
      get edit_spot_review_path(spot, review)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
