require "test_helper"

class MainUserFlowTest < ActionDispatch::IntegrationTest
  test "ログインしてスポットを閲覧し口コミを投稿編集削除できる" do
    user = create(:user)
    spot = create(:spot)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
    assert_response :redirect

    get spots_path
    assert_response :success
    assert_select "body", text: /#{Regexp.escape(spot.name)}/

    get spot_path(spot)
    assert_response :success
    assert_select "h1", text: spot.name

    assert_difference("Review.count", 1) do
      post spot_reviews_path(spot), params: {
        review: {
          rating: 5,
          body: "主要機能テストの口コミです。",
          good_point: "景色がきれいでした。",
          bad_point: "少し混雑していました。",
          season: "spring",
          purpose: "sightseeing",
          companion_type: "couple"
        }
      }
    end

    review = Review.find_by!(user: user, spot: spot)

    assert_redirected_to spot_path(spot)
    follow_redirect!
    assert_response :success
    assert_select "body", text: /主要機能テストの口コミです。/

    get edit_spot_review_path(spot, review)
    assert_response :success

    patch spot_review_path(spot, review), params: {
      review: {
        rating: 4,
        body: "編集後の主要機能テストの口コミです。",
        good_point: "落ち着いて楽しめました。",
        bad_point: "アクセスに時間がかかりました。",
        season: "autumn",
        purpose: "sightseeing",
        companion_type: "friends"
      }
    }

    assert_redirected_to spot_path(spot)

    review.reload
    assert_equal 4, review.rating
    assert_equal "編集後の主要機能テストの口コミです。", review.body
    assert_equal "autumn", review.season

    assert_difference("Review.count", -1) do
      delete spot_review_path(spot, review)
    end

    assert_redirected_to spot_path(spot)
    assert_not Review.exists?(review.id)
  end
end
