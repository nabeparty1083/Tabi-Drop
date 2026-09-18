require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

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
end
