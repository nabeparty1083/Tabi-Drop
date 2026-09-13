require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @spot = spots(:arashiyama)
    @review = reviews(:one)
    @other_review = reviews(:two)
  end

  test "未ログインでは口コミ投稿フォームを開けない" do
   get new_spot_review_path(@spot)

   assert_redirected_to new_user_session_path
  end

  test "ログイン中は口コミ投稿フォームを開ける" do
    sign_in @user

    get new_spot_review_path(@spot)

    assert_response :success
    assert_select "h1", text: "#{@spot.name}の口コミを投稿"
  end

  test "正しい入力なら口コミを投稿できる" do
    sign_in @user

    assert_difference "Review.count", 1 do
      post spot_reviews_path(@spot), params: {
        review: {
          rating: 5,
          body: "とても素敵なスポットでした。",
          good_point: "景色がきれいでした。",
          bad_point: "少し混雑していました。",
          season: "spring",
          purpose: "sightseeing",
          companion_type: "couple"
        }
      }
    end

    review = Review.find_by(user: @user, spot: @spot)

    assert_equal 5, review.rating
    assert_equal "とても素敵なスポットでした。", review.body
    assert_equal "spring", review.season
    assert_equal "published", review.status
    assert_redirected_to spot_path(@spot)
  end

  test "入力に不備がある場合は口コミを投稿できない" do
    sign_in @user

    assert_no_difference "Review.count" do
      post spot_reviews_path(@spot), params: {
        review: {
          rating: "",
          body: "",
          season: "",
          purpose: "",
          companion_type: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h2", text: "入力内容を確認してください"
  end

  test "同じユーザーは同じスポットに複数投稿できない" do
    sign_in @user
    posted_spot = spots(:kiyomizu)

    assert_no_difference "Review.count" do
      post spot_reviews_path(posted_spot), params: {
        review: {
          rating: 4,
          body: "もう一度投稿します。",
          season: "autumn",
          purpose: "sightseeing",
          companion_type: "friends"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "li",
                  text: "投稿者はこのスポットにすでに口コミを投稿しています"
  end
  test "自分の口コミの編集フォームを開ける" do
  sign_in @user

  get edit_spot_review_path(@review.spot, @review)

  assert_response :success
  assert_select "h1", text: "#{@review.spot.name}の口コミを編集"
  assert_select "textarea[name='review[body]']",
                text: @review.body
end

test "自分の口コミを更新できる" do
  sign_in @user

  patch spot_review_path(@review.spot, @review), params: {
    review: {
      rating: 3,
      body: "編集後の口コミです。",
      good_point: "落ち着いた景色でした。",
      bad_point: "少し混雑していました。",
      season: "winter",
      purpose: "sightseeing",
      companion_type: "couple"
    }
  }

  @review.reload

  assert_equal 3, @review.rating
  assert_equal "編集後の口コミです。", @review.body
  assert_equal "winter", @review.season
  assert_redirected_to spot_path(@review.spot)
end

test "入力に不備がある場合は口コミを更新できない" do
  sign_in @user
  original_body = @review.body

  patch spot_review_path(@review.spot, @review), params: {
    review: {
      rating: "",
      body: "",
      season: "",
      purpose: "",
      companion_type: ""
    }
  }

  assert_response :unprocessable_entity
  assert_equal original_body, @review.reload.body
  assert_select "h2", text: "入力内容を確認してください"
end

test "他ユーザーの口コミの編集フォームを開けない" do
  sign_in @user

  get edit_spot_review_path(@other_review.spot, @other_review)

  assert_response :not_found
 end

test "他ユーザーの口コミを更新できない" do
  sign_in @user
  original_body = @other_review.body

  patch spot_review_path(@other_review.spot, @other_review), params: {
    review: {
      rating: 1,
      body: "勝手に編集した内容"
    }
  }

  assert_response :not_found
  assert_equal original_body, @other_review.reload.body
end
end
