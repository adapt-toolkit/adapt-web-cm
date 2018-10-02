class Collectible < ApplicationRecord
  belongs_to :category

  has_many :reserves, dependent: :destroy

  mount_uploader :collectible_file, CollectibleFileUploader
  mount_uploader :json_file, JsonFileUploader

  validates :category_id, :collectible_file, presence: true
  validate :validate_json, if: -> { json_file_has_just_been_uploaded }

  validates :collectible_file_name, format: { with: /\.\w+\z/i, message: 'doesn\'t have an extension' },
                                    if: -> { collectible_file_name_changed }
  validates :json_file_name, format: { with: /\.\w+\z/i, message: 'doesn\'t have an extension' },
                             if: -> { json_file_name_changed }

  before_create :set_sort_order, if: -> { sort_order === 0 }

  # Uploads renaming
  before_update :rename_collectible_file, if: -> { collectible_file_name_changed && !collectible_file_has_just_been_uploaded }
  before_update :rename_json_file,        if: -> { json_file_name_changed && !json_file_has_just_been_uploaded }

  # Autoremove old uploads if the new ones is coming.
  before_update :autoremove_collectible_file, if: -> { collectible_file_has_just_been_uploaded }
  before_update :autoremove_json_file,        if: -> { json_file_has_just_been_uploaded }

  after_save :tmp_files_cleanup
  after_save :copy_files_to_public_web_static_folder
  after_destroy :delete_files_from_public_web_static_folder

  attr_accessor :collectible_file_base64, :collectible_file_name, :collectible_file_has_just_been_uploaded,
                :json_file_base64,        :json_file_name,        :json_file_has_just_been_uploaded

  # Marks that file has just been uploaded
  def collectible_file=(obj)
    super(obj)
    self.collectible_file_has_just_been_uploaded = (collectible_file == collectible_file_was)
  end
  def json_file=(obj)
    super(obj)
    self.json_file_has_just_been_uploaded = (json_file == json_file_was)
  end

  # Base64 Decode (drag'n'dropped files)
  def collectible_file_base64=(obj)
    if obj.present?
      base = obj.split(',')[1] # getting only the string leaving out the data/<format>
      self.collectible_file = file_decode64(base, collectible_file_name)
    end
  end
  def json_file_base64=(obj)
    if obj.present?
      base = obj.split(',')[1] # getting only the string leaving out the data/<format>
      self.json_file = file_decode64(base, json_file_name)
    end
  end

  # For sort_order functionality
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

  def file_decode64(base, filename)
    file = Tempfile.new(['decoded-', ".#{filename.split('.')[-1]}"])
    file.binmode
    file.write(Base64.decode64(base))
    file.close
    clean_after_save file
    file
  end

  def collectible_file_name_changed
    collectible_file_name.present? && collectible_file_name != "#{hashsum}.#{ext}"
  end
  def json_file_name_changed
    json_file_name.present? && json_file_name != json_file.try(:file).try(:filename)
  end

  def validate_json
    json = JSON.parse(json_file.file.read)

    if json['title'] === nil
      errors.add(:json_file, "doesn't have a `title`")
    end

    if json['properties'] === nil
      errors.add(:json_file, "doesn't have `properties`")
    else
      %w( name description image license ).each do |prop_name|
        validate_property json['properties'], prop_name
      end
    end

    # Ensure this line is before the SHA3 digest check
    if not errors[:collectible_file].empty?
      errors.add(:json_file, "can't be fully validated because of validation errors with image file")
    end

    if errors[:json_file].empty?
      if not json['properties']['image']['description'].start_with? SHA3::Digest::SHA256.hexdigest(collectible_file.file.read)
        errors.add(:json_file, "has image file name that doesn't match with calculated image hash")
      end

      digest = SHA3::Digest::SHA256.new
      digest.update SHA3::Digest::SHA256.digest(collectible_file.file.read)
      digest.update json['properties']['name']['description']
      digest.update json['properties']['description']['description']
      digest.update json['properties']['license']['description']

      json_hash = digest.hexdigest

      if not json_file_name.start_with?(json_hash)
        errors.add(:json_file, "name doesn't match with calculated json hash")
      end
    end
  rescue JSON::ParserError
    errors.add(:json_file, "parser error has occured")
  end

  # This function is used by `validate_json`
  def validate_property(props, prop_name)
    if props[prop_name] === nil
      errors.add(:json_file, "doesn't have `properties.#{prop_name}`")
    else
      if props[prop_name]['type'] === nil
        errors.add(:json_file, "doesn't have `properties.#{prop_name}.type`")
      elsif props[prop_name]['type'] != "string"
        errors.add(:json_file, "has incorrect `properties.#{prop_name}.type`")
      end                  
      if props[prop_name]['description'] === nil
        errors.add(:json_file, "doesn't have `properties.#{prop_name}.description`")
      end
    end
  end

  def set_sort_order
    self.sort_order = (last_record.try(:sort_order) || 0) + 100
  end

  def rename_collectible_file
    # Renaming downsized preview
    src  = File.join(Rails.configuration.coll_preview_storage_path, hashsum+"."+ext)
    dest = File.join(Rails.configuration.coll_preview_storage_path, collectible_file_name+"."+ext)
    File.rename(src, dest) if File.exist?(src)
                
    # Renaming original collectible
    src  = File.join(Rails.configuration.coll_preview_storage_path, hashsum+"-original."+ext)
    dest = File.join(Rails.configuration.coll_preview_storage_path, collectible_file_name+"-original."+ext)
    File.rename(src, dest) if File.exist?(src)

    # Renaming collectible in p/ folder
    src  = File.join(Rails.configuration.collectibles_storage_path, hashsum)
    dest = File.join(Rails.configuration.collectibles_storage_path, collectible_file_name)
    File.rename(src, dest) if File.exist?(src)

    self.hashsum = collectible_file_name
  end

  def rename_json_file
    # Renaming JSON file in j/ folder
    src  = File.join(Rails.configuration.json_storage_path, json_file.file.basename)
    dest = File.join(Rails.configuration.json_storage_path, json_file_name)
    File.rename(src, dest) if File.exist?(src)

    # Renaming upload itself
    json_file.file.move! json_file.path.sub(json_file.file.filename, json_file_name+'.json')

    self["json_file"] = json_file_name+'.json'
  end

  def autoremove_collectible_file
    if hashsum_was.present?
      path_to_coll_preview_file = File.join(Rails.configuration.coll_preview_storage_path, hashsum_was+"."+ext_was)
      File.delete(path_to_coll_preview_file) if File.exist?(path_to_coll_preview_file)

      path_to_coll_preview_file = File.join(Rails.configuration.coll_preview_storage_path, hashsum_was+"-original."+ext_was)
      File.delete(path_to_coll_preview_file) if File.exist?(path_to_coll_preview_file)

      path_to_collectible_file = File.join(Rails.configuration.collectibles_storage_path, hashsum_was)
      File.delete(path_to_collectible_file) if File.exist?(path_to_collectible_file)
    end
  end
  def autoremove_json_file
    filename_was = json_file_was.try(:file).try(:filename)
    if filename_was.present?
      path_to_json_file = File.join(Rails.configuration.json_storage_path, File.basename(filename_was, ".*"))
      File.delete(path_to_json_file) if File.exist?(path_to_json_file)
    end
  end

  def copy_files_to_public_web_static_folder
    if collectible_file_has_just_been_uploaded
      # Downsized collectible image for preview purposes
      FileUtils.cp(collectible_file.thumb.path,
              File.join(Rails.configuration.coll_preview_storage_path, hashsum+"."+ext))
      # Collectible image in original dimensions
      FileUtils.cp(collectible_file.path,
              File.join(Rails.configuration.coll_preview_storage_path, hashsum+"-original."+ext))

    # Collectible file in /p folder
    FileUtils.cp(collectible_file.path,
      File.join(Rails.configuration.collectibles_storage_path, hashsum))
    end

    # JSON file in /j folder
    FileUtils.cp(json_file.path,
      File.join(Rails.configuration.json_storage_path, json_file.file.basename)) if json_file_has_just_been_uploaded
  end

  def delete_files_from_public_web_static_folder
    # Cleaning up downsized collectible image
    path_to_coll_preview_file = File.join(Rails.configuration.coll_preview_storage_path, hashsum+"."+ext)
    File.delete(path_to_coll_preview_file) if File.exist?(path_to_coll_preview_file)

    # Collectible image in original dimensions
    path_to_coll_preview_file = File.join(Rails.configuration.coll_preview_storage_path, hashsum+"-original."+ext)
    File.delete(path_to_coll_preview_file) if File.exist?(path_to_coll_preview_file)

    # Collectible file in /p folder
    path_to_collectible_file = File.join(Rails.configuration.collectibles_storage_path, hashsum)
    File.delete(path_to_collectible_file) if File.exist?(path_to_collectible_file)

    if json_file.present?
      # JSON file in /j folder
      path_to_json_file = File.join(Rails.configuration.json_storage_path, json_file.file.basename)
      File.delete(path_to_json_file) if File.exist?(path_to_json_file)
    end
  end

  def clean_after_save(file)
    @tmp_files_to_cleanup ||= []
    @tmp_files_to_cleanup << file
  end

  def tmp_files_cleanup
    (@tmp_files_to_cleanup || []).each do |file|
      file.unlink
    end
  end
end
