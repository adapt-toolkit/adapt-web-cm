class Category < ApplicationRecord
  has_many :collectibles, dependent: :destroy

  validates :keyword, :title, presence: true
end
