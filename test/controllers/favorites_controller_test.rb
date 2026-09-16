require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @spot = spots(:arashiyama)
  end

  test "ログインユーザーがお気に入り登録できる" do
    sign_in @user

    assert_difference("Favorite.count", 1) do
      post spot_favorite_path(@spot)
    end

    assert_redirected_to spot_path(@spot)
    assert @user.favorites.exists?(spot: @spot)
  end

  test "同じスポットを重複してお気に入り登録しない" do
    sign_in @user
    registered_spot = spots(:kiyomizu)

    assert_no_difference("Favorite.count") do
      post spot_favorite_path(registered_spot)
    end

    assert_redirected_to spot_path(registered_spot)
  end

  test "ログインユーザーがお気に入りを解除できる" do
    sign_in @user
    registered_spot = spots(:kiyomizu)

    assert_difference("Favorite.count", -1) do
      delete spot_favorite_path(registered_spot)
    end

    assert_redirected_to spot_path(registered_spot)
    assert_not @user.favorites.exists?(spot: registered_spot)
  end

  test "未ログインではお気に入り登録できない" do
    assert_no_difference("Favorite.count") do
      post spot_favorite_path(@spot)
    end

    assert_redirected_to new_user_session_path
  end

  test "未ログインではお気に入り解除できない" do
    registered_spot = spots(:kiyomizu)

    assert_no_difference("Favorite.count") do
      delete spot_favorite_path(registered_spot)
    end

    assert_redirected_to new_user_session_path
  end
end
