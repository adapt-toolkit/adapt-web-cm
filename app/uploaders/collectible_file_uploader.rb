class CollectibleFileUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process :store_collectible_file_attrs

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [240, 960]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   if original_filename
  #     sha256 = Digest::SHA256.file(file.file)
  #     "#{sha256.hexdigest}.#{file.extension}"
  #   end
  # end

  private

  def store_collectible_file_attrs
    if file && model
      filename = model.collectible_file_name.presence || file.filename

      ext     = File.extname  filename
      hashsum = File.basename filename, ext

      model.hashsum = hashsum # || SHA3::Digest::SHA256.file(file.file).hexdigest
      model.ext     = ext[1..-1]

      model.width, model.height = `identify -format "%wx%h" #{file.path}`.split(/x/)
    end
  end
end
