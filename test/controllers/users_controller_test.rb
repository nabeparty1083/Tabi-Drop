require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)

    @published_review = Review.create!(
      user: @user,
      spot: spots(:arashiyama),
      rating: 5,
      body: "プロフィールに表示する公開口コミです。",
      good_point: "景色がきれいです。",
      bad_point: "混雑することがあります。",
      season: :spring,
      status: :published,
      purpose: :sightseeing,
      companion_type: :solo
    )
  end

  test "プロフィールを表示できる" do
    get user_path(@user)

    assert_response :success
    assert_includes response.body, @user.name
    assert_includes response.body, @user.residence
    assert_includes response.body, @user.bio
  end

  test "公開中の口コミを表示できる" do
    get user_path(@user)

    assert_response :success
    assert_includes response.body, @published_review.body
    assert_includes response.body, @published_review.spot.name
  end

  test "非公開の口コミは表示されない" do
    hidden_review = reviews(:one)

    get user_path(@user)

    assert_response :success
    assert_not_includes response.body, hidden_review.body
  end

  test "ログインユーザー自身のプロフィールを表示できる" do
    sign_in @user

    get user_path(@user)

    assert_response :success
    assert_includes response.body, @user.name
  end

  test "存在しないユーザーは404になる" do
    get user_path(id: 999_999)

    assert_response :not_found
  end

  test "未ログインではプロフィール編集画面を表示できない" do
    get edit_user_path(@user)

    assert_redirected_to new_user_session_path
  end

  test "ログインユーザーは自分のプロフィールを編集できる" do
    sign_in @user

    get edit_user_path(@user)

    assert_response :success
    assert_includes response.body, "プロフィール編集"
  end

  test "他のユーザーのプロフィール編集画面を表示できない" do
    sign_in @user

    get edit_user_path(@other_user)

    assert_redirected_to user_path(@other_user)
  end

  test "プロフィールを更新できる" do
    sign_in @user

    patch user_path(@user), params: {
      user: {
        name: "更新後の名前",
        residence: "大阪府",
        bio: "更新後の自己紹介です。"
      }
    }

    assert_redirected_to user_path(@user)

    @user.reload
    assert_equal "更新後の名前", @user.name
    assert_equal "大阪府", @user.residence
    assert_equal "更新後の自己紹介です。", @user.bio
  end

  test "他のユーザーのプロフィールを更新できない" do
    sign_in @user
    original_name = @other_user.name

    patch user_path(@other_user), params: {
      user: {
        name: "不正に変更した名前"
      }
    }

    assert_redirected_to user_path(@other_user)
    assert_equal original_name, @other_user.reload.name
  end

  test "入力内容が不正な場合はプロフィールを更新できない" do
    sign_in @user
    original_name = @user.name

    patch user_path(@user), params: {
      user: {
        name: "あ" * 31
      }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @user.reload.name
    assert_includes response.body, "入力内容を確認してください"
  end

  test "自分のプロフィールにだけ編集リンクを表示する" do
    sign_in @user

    get user_path(@user)
    assert_includes response.body, "プロフィールを編集する"

    get user_path(@other_user)
    assert_not_includes response.body, "プロフィールを編集する"
  end
end
