class Collectible < ApplicationRecord
  belongs_to :category

  has_many :reserves, dependent: :destroy

  mount_uploader :collectible_file, CollectibleFileUploader
  mount_uploader :json_file, JsonFileUploader

  before_create :set_sort_order, if: -> { sort_order === 0 }

  after_save :copy_coll_file_to_public_web_static_folder
  after_destroy :delete_coll_file_from_public_web_static_folder


  def prev_record
    Collectible.where('sort_order < ?', sort_order).order(sort_order: :desc, created_at: :desc).first
  end

  def next_record
    Collectible.where('sort_order > ?', sort_order).order(sort_order: :asc, created_at: :asc).first
  end

  def last_record
    Collectible.order(sort_order: :desc, created_at: :desc).first
  end

  private

  def set_sort_order
    self.sort_order = (last_record.try(:sort_order) || 0) + 100
  end

  def copy_coll_file_to_public_web_static_folder
    # Downsized collectible for preview purposes
    FileUtils.cp(collectible_file.thumb.path,
              File.join(Rails.configuration.coll_preview_storage_path, collectible_file.file.filename)) if collectible_file.present?

    # Collectible file & JSON file
    FileUtils.cp(collectible_file.path,
      File.join(Rails.configuration.collectibles_storage_path, File.basename(collectible_file.file.filename, ".*"))) if collectible_file.present?
    FileUtils.cp(json_file.path,
      File.join(Rails.configuration.json_storage_path, File.basename(json_file.file.filename, ".*"))) if json_file.present?
  end

  def delete_coll_file_from_public_web_static_folder
    path_to_coll_preview_file = File.join(Rails.configuration.coll_preview_storage_path, collectible_file.file.filename)
    File.delete(path_to_coll_preview_file) if File.exist?(path_to_coll_preview_file)

    path_to_collectible_file = File.join(Rails.configuration.collectibles_storage_path, File.basename(collectible_file.file.filename, ".*"))
    File.delete(path_to_collectible_file) if File.exist?(path_to_collectible_file)

    path_to_json_file = File.join(Rails.configuration.json_storage_path, File.basename(json_file.file.filename, ".*"))
    File.delete(path_to_json_file) if File.exist?(path_to_json_file)
  end
end
