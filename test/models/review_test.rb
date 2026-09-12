require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "必要な項目があれば登録できる" do
    assert reviews(:one).valid?
  end

  test "評価が空欄なら登録できない" do
    review = reviews(:one)
    review.rating = nil

    assert_not review.valid?
    assert review.errors[:rating].any?
  end

  test "評価は1から5の範囲である" do
    review = reviews(:one)

    [ 0, 6 ].each do |rating|
      review.rating = rating

      assert_not review.valid?
      assert review.errors[:rating].any?
    end
  end

  test "必須項目が空欄なら登録できない" do
    %i[body season status purpose companion_type].each do |attribute|
      review = reviews(:one).dup
      review[attribute] = nil
      review.valid?

      assert review.errors[attribute].any?
    end
  end

  test "同じユーザーは同じスポットに複数の口コミを登録できない" do
    review = reviews(:one).dup

    assert_not review.valid?
    assert review.errors[:user_id].any?
  end
end
