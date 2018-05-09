class Collectible < ApplicationRecord
  belongs_to :category

  has_many :reserves, dependent: :destroy

  mount_uploader :collectible_file, CollectibleFileUploader
end
