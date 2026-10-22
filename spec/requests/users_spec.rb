require "rails_helper"

RSpec.describe "プロフィール", type: :request do
  let(:user) { create(:user, email: "profile@example.com") }

  describe "GET /users/:id/edit" do
    it "未ログインの場合はログイン画面へ移動する" do
      get edit_user_path(user)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "本人の場合は編集画面を表示できる" do
      sign_in user

      get edit_user_path(user)

      expect(response).to have_http_status(:ok)
    end

    it "他人の場合は対象ユーザーのプロフィール詳細へ移動する" do
      other_user = create(:user, email: "other@example.com")
      sign_in other_user

      get edit_user_path(user)

      expect(response).to redirect_to(user_path(user))
    end
  end

    describe "PATCH /users/:id" do
    let(:updated_attributes) do
      {
        name: "更新後の名前",
        residence: "京都府",
        bio: "京都のカフェ巡りが好きです"
      }
    end

    it "未ログインの場合は更新されずログイン画面へ移動する" do
      expect {
        patch user_path(user), params: { user: updated_attributes }
      }.not_to change {
        user.reload.attributes.slice("name", "residence", "bio")
      }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "本人の場合はプロフィールを更新できる" do
      sign_in user

      patch user_path(user), params: { user: updated_attributes }

      expect(response).to redirect_to(user_path(user))
      expect(user.reload).to have_attributes(updated_attributes)
    end

    it "入力が不正な場合は更新されず編集画面を再表示する" do
      sign_in user
      invalid_attributes = updated_attributes.merge(name: "あ" * 31)

      expect {
        patch user_path(user), params: { user: invalid_attributes }
      }.not_to change {
        user.reload.attributes.slice("name", "residence", "bio")
      }

      expect(response).to have_http_status(422)
    end

    it "他人の場合は更新されず対象ユーザーのプロフィール詳細へ移動する" do
      other_user = create(:user, email: "other@example.com")
      sign_in other_user

      expect {
        patch user_path(user), params: { user: updated_attributes }
      }.not_to change {
        user.reload.attributes.slice("name", "residence", "bio")
      }

      expect(response).to redirect_to(user_path(user))
    end
  end
end
