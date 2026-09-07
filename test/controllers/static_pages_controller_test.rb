require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "top-test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "未ログインの場合はログインと新規登録を表示する" do
    get root_url

    assert_response :success
    assert_select "a[href=?]", new_user_session_path, text: "ログイン"
    assert_select "a[href=?]", new_user_registration_path, text: "新規登録"
    assert_select "a[href=?]", destroy_user_session_path, count: 0
  end

  test "ログイン済みの場合はマイページとログアウトを表示する" do
    sign_in @user

    get root_url

    assert_response :success
    assert_select "a[href=?]", mypage_path, text: "マイページ"
    assert_select "a[href=?]", destroy_user_session_path, text: "ログアウト"
    assert_select "a[href=?]", new_user_session_path, count: 0
  end
end
