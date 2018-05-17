class Collectible < ApplicationRecord
  belongs_to :category

  has_many :reserves, dependent: :destroy

  mount_uploader :collectible_file, CollectibleFileUploader

  after_save :copy_coll_file_to_public_web_static_folder
  after_destroy :delete_coll_file_from_public_web_static_folder

  private

  def copy_coll_file_to_public_web_static_folder
    collectible_file.file.copy_to(Rails.configuration.collectibles_storage_path)
  end

  def delete_coll_file_from_public_web_static_folder
    path_to_file = "#{Rails.configuration.collectibles_storage_path}#{collectible_file.file.filename}"
    File.delete(path_to_file) if File.exist?(path_to_file)
  end  
end
