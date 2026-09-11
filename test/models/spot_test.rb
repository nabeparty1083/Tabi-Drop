require "test_helper"

class SpotTest < ActiveSupport::TestCase
  setup do
    @spot = Spot.new(
      name: "伏見稲荷大社",
      prefecture: "京都府",
      city: "京都市伏見区",
      address: "深草藪之内町68",
      category: :sightseeing
    )
  end

  test "正しい内容なら登録できる" do
    assert @spot.valid?
  end

  test "必須項目が空欄なら登録できない" do
    %i[name prefecture city address category].each do |attribute|
      @spot[attribute] = nil

      assert_not @spot.valid?
      assert @spot.errors[attribute].present?

      @spot[attribute] = attribute == :category ? :sightseeing : "入力内容"
    end
  end

  test "スポット名と住所の組み合わせは重複できない" do
    @spot.save!
    duplicate_spot = @spot.dup

    assert_not duplicate_spot.valid?
    assert duplicate_spot.errors[:name].present?
  end

  test "カテゴリーが正しい整数に対応している" do
    assert_equal 0, Spot.categories["sightseeing"]
    assert_equal 6, Spot.categories["other"]
  end
end
