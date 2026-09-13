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
end
