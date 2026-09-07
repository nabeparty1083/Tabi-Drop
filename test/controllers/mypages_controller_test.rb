require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "mypage-test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "未ログインの場合はログイン画面へ移動する" do
    get mypage_url

    assert_redirected_to new_user_session_url
  end

  test "ログイン済みの場合はマイページを表示できる" do
    sign_in @user

    get mypage_url

    assert_response :success
  end
end
