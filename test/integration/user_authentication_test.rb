require "test_helper"

class UserAuthenticationTest < ActionDispatch::IntegrationTest
  test "正しい情報でユーザー登録できる" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          email: "new_user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :redirect
    assert User.exists?(email: "new_user@example.com")

    get mypage_path
    assert_response :success
  end

  test "パスワード確認が一致しない場合はユーザー登録できない" do
    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "invalid_user@example.com",
          password: "password",
          password_confirmation: "different_password"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "正しいメールアドレスとパスワードでログインできる" do
    user = create(:user)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }

    assert_response :redirect

    get mypage_path
    assert_response :success
  end

  test "誤ったパスワードではログインできない" do
    user = create(:user)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "wrong_password"
      }
    }

    assert_response :unprocessable_entity

    get mypage_path
    assert_redirected_to new_user_session_path
  end
  test "登録済みメールアドレスの存在をエラーメッセージから推測できない" do
   create(:user, email: "existing@example.com")

    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "existing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "入力内容をご確認ください"
    assert_not_includes response.body, "すでに使用されています"
  end
    test "パスワード再設定ではメールアドレスの登録状況を判別できない" do
    user = create(:user)

    post user_password_path, params: {
      user: { email: "not_registered@example.com" }
    }
    unregistered_message = flash[:notice]

    post user_password_path, params: {
      user: { email: user.email }
    }
    registered_message = flash[:notice]

    assert_response :redirect
    assert_equal registered_message, unregistered_message
  end

  test "ログイン失敗時はメールアドレスの登録状況を判別できない" do
    user = create(:user)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "wrong_password"
      }
    }
    registered_message = flash[:alert]

    post user_session_path, params: {
      user: {
        email: "not_registered@example.com",
        password: "wrong_password"
      }
    }
    unregistered_message = flash[:alert]

    assert_response :unprocessable_entity
    assert_equal registered_message, unregistered_message
  end
end
