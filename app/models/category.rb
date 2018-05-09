class Category < ApplicationRecord
  has_many :collectibles, dependent: :destroy
end
