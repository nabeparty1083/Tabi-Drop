require "test_helper"

class SpotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spot = spots(:kiyomizu)
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
end
