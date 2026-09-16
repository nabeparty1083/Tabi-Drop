class Spot < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user

  enum :category, {
    sightseeing: 0,
    gourmet: 1,
    cafe: 2,
    shopping: 3,
    accommodation: 4,
    activity: 5,
    other: 6
  }

  validates :name, presence: true,
                   uniqueness: { scope: :address }
  validates :prefecture, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :category, presence: true
end
