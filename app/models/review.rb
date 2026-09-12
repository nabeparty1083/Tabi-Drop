class Review < ApplicationRecord
  belongs_to :user
  belongs_to :spot

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :body, :season, :status, :purpose, :companion_type, presence: true
  validates :user_id, uniqueness: { scope: :spot_id }
end
