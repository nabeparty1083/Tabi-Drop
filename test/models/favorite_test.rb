require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  test "ユーザーとスポットがあれば有効である" do
    favorite = Favorite.new(
      user: users(:one),
      spot: spots(:arashiyama)
    )

    assert favorite.valid?
  end

  test "同じユーザーが同じスポットを重複してお気に入り登録できない" do
    favorite = Favorite.new(
      user: users(:one),
      spot: spots(:kiyomizu)
    )

    assert_not favorite.valid?
  end
end
