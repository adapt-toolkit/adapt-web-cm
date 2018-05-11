class Collectible < ApplicationRecord
  belongs_to :category

  has_many :reserves, dependent: :destroy

  mount_uploader :collectible_file, CollectibleFileUploader

  after_save :symlink_collectible

  private

  def symlink_collectible
    if Rails.configuration.try(:collectibles_storage_path)
      collectible_file.file.copy_to(Rails.configuration.collectibles_storage_path)
    end
  end
end
