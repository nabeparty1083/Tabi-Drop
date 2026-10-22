require "rails_helper"

RSpec.describe "認証", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/sign_in" do
    it "正しい情報でログインできる" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }

      expect(response).to have_http_status(:see_other)

      get edit_user_path(user)

      expect(response).to have_http_status(:ok)
    end

    it "誤ったパスワードではログインできない" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "wrong_password"
        }
      }

      expect(response).to have_http_status(422)

      get edit_user_path(user)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "未登録のメールアドレスではログインできない" do
      post user_session_path, params: {
        user: {
          email: "not_registered@example.com",
          password: "password123"
        }
      }

      expect(response).to have_http_status(422)

      get edit_user_path(user)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE /users/sign_out" do
    it "ログアウト後はプロフィール編集画面にアクセスできない" do
      sign_in user

      get edit_user_path(user)

      expect(response).to have_http_status(:ok)

      delete destroy_user_session_path

      expect(response).to have_http_status(:see_other)

      get edit_user_path(user)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

    describe "メールアドレスの登録状況を隠す応答" do
    it "ログイン失敗時は登録済み・未登録で同じメッセージを返す" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "wrong_password"
        }
      }

      expect(response).to have_http_status(422)
      registered_message = flash[:alert]
      expect(registered_message).to be_present

      post user_session_path, params: {
        user: {
          email: "not_registered@example.com",
          password: "wrong_password"
        }
      }

      expect(response).to have_http_status(422)
      expect(flash[:alert]).to eq(registered_message)
    end

    it "パスワード再設定時は登録済み・未登録で同じ案内を返す" do
      post user_password_path, params: {
        user: { email: user.email }
      }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_user_session_path)

      registered_message = flash[:notice]
      expect(registered_message).to be_present

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(registered_message)

      post user_password_path, params: {
        user: { email: "not_registered@example.com" }
      }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to eq(registered_message)

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(registered_message)
    end
  end

    describe "POST /users" do
    let(:registration_attributes) do
      {
        email: "new_user@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    it "正しい入力でユーザー登録できログイン状態になる" do
      expect {
        post user_registration_path, params: {
          user: registration_attributes
        }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:see_other)

      registered_user = User.find_by!(
        email: registration_attributes[:email]
      )

      get edit_user_path(registered_user)

      expect(response).to have_http_status(:ok)
    end

    it "パスワード確認が一致しない場合は登録できない" do
      invalid_attributes = registration_attributes.merge(
        password_confirmation: "different_password"
      )

      expect {
        post user_registration_path, params: {
          user: invalid_attributes
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("処理を完了できませんでした")
      expect(response.body).to include("入力内容をご確認ください")
    end

    it "登録済みメールでは登録できず重複を示すエラーを表示しない" do
      create(:user, email: registration_attributes[:email])

      expect {
        post user_registration_path, params: {
          user: registration_attributes
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("処理を完了できませんでした")
      expect(response.body).to include("入力内容をご確認ください")
      expect(response.body).not_to include("すでに使用されています")
    end
  end
end
