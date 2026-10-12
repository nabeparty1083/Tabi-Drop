require "rails_helper"

RSpec.describe Review, type: :model do
  it "必要な項目がそろっていれば有効である" do
    review = build(:review)

    expect(review).to be_valid
  end

  it "本文が空欄なら無効である" do
    review = build(:review, body: nil)

    expect(review).not_to be_valid
    expect(review.errors[:body]).to be_present
  end

  it "評価が6なら無効である" do
    review = build(:review, rating: 6)

    expect(review).not_to be_valid
    expect(review.errors[:rating]).to be_present
  end
end
