require "test_helper"

class SpotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spot = spots(:kiyomizu)
    @user = users(:one)
    @review = reviews(:one)
  end

  test "should get index" do
    get spots_url

    assert_response :success
    assert_select "h1", text: "スポット一覧"
    assert_select "h2", text: @spot.name
  end

  test "should get show" do
    get spot_url(@spot)

    assert_response :success
    assert_select "h1", text: @spot.name
  end

  test "自分の口コミがある場合は削除ボタンが表示される" do
    sign_in @user
    get spot_url(@review.spot)

    assert_response :success
    assert_select "form[action='#{spot_review_path(@review.spot, @review)}']" do
      assert_select "input[name='_method'][value='delete']"
      assert_select "button", text: "自分の口コミを削除する"
    end
  end

  test "未ログインの場合は口コミ削除ボタンが表示されない" do
    get spot_url(@review.spot)

    assert_response :success
    assert_select "button", text: "自分の口コミを削除する", count: 0
  end

  test "お気に入り登録済みの場合は解除ボタンが表示される" do
  sign_in @user

  get spot_url(@spot)

  assert_response :success
  assert_select "form[action='#{spot_favorite_path(@spot)}']" do
    assert_select "input[name='_method'][value='delete']"
    assert_select "button", text: "★ お気に入りを解除する"
  end
end

test "お気に入り未登録の場合は登録ボタンが表示される" do
  sign_in @user
  unregistered_spot = spots(:arashiyama)

  get spot_url(unregistered_spot)

  assert_response :success
  assert_select "form[action='#{spot_favorite_path(unregistered_spot)}']" do
    assert_select "button", text: "☆ お気に入りに登録する"
  end
end

test "未ログインの場合はお気に入りボタンが表示されない" do
  get spot_url(@spot)

  assert_response :success
  assert_select "button", text: "★ お気に入りを解除する", count: 0
  assert_select "button", text: "☆ お気に入りに登録する", count: 0
end

  test "都道府県でスポットを絞り込める" do
    osaka_spot = create_osaka_cafe

    get spots_url, params: { prefecture: "大阪府" }

    assert_response :success
    assert_select "h2", text: osaka_spot.name
    assert_select "h2", text: @spot.name, count: 0
  end

  test "カテゴリーでスポットを絞り込める" do
    osaka_spot = create_osaka_cafe

    get spots_url, params: { category: "cafe" }

    assert_response :success
    assert_select "h2", text: osaka_spot.name
    assert_select "h2", text: @spot.name, count: 0
  end

  test "公開中の口コミの季節でスポットを絞り込める" do
    @review.update!(season: :spring, status: :published)

    get spots_url, params: { season: "spring" }

    assert_response :success
    assert_select "h2", text: @review.spot.name
  end

  test "公開中の口コミの同行者でスポットを絞り込める" do
    @review.update!(companion_type: :family, status: :published)

    get spots_url, params: { companion_type: "family" }

    assert_response :success
    assert_select "h2", text: @review.spot.name
  end

  test "複数の条件を組み合わせて絞り込める" do
    @review.update!(
      season: :spring,
      companion_type: :family,
      status: :published
    )

    get spots_url, params: {
      prefecture: "京都府",
      category: "sightseeing",
      season: "spring",
      companion_type: "family"
    }

    assert_response :success
    assert_select "h2", text: @review.spot.name
  end

  test "条件に一致するスポットがない場合はメッセージを表示する" do
    get spots_url, params: { prefecture: "大阪府" }

    assert_response :success
    assert_select "p", text: "条件に一致するスポットはありません。"
  end

  private

  def create_osaka_cafe
    Spot.create!(
      name: "テストカフェ",
      prefecture: "大阪府",
      city: "大阪市",
      address: "テスト町1丁目",
      category: :cafe
    )
  end
end
