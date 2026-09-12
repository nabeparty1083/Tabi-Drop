class Review < ApplicationRecord
  belongs_to :user
  belongs_to :spot

  enum :season, {
    spring: 0,
    summer: 1,
    autumn: 2,
    winter: 3
  }

  enum :status, {
    published: 0,
    hidden: 1
  }

  enum :purpose, {
    sightseeing: 0,
    gourmet: 1,
    relaxation: 2,
    shopping: 3,
    activity: 4
  }

  enum :companion_type, {
    solo: 0,
    couple: 1,
    friends: 2,
    family: 3,
    with_children: 4
  }

  validates :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :body, :season, :status, :purpose, :companion_type, presence: true
  validates :user_id,
            uniqueness: {
              scope: :spot_id,
              message: "はこのスポットにすでに口コミを投稿しています"
            }
end
