class ReviewImageUploader < CarrierWave::Uploader::Base
  if Rails.env.test?
    storage :file
  else
    include Cloudinary::CarrierWave
  end

  def extension_allowlist
    %w[jpg jpeg png webp]
  end

  def content_type_allowlist
    %r{\Aimage/(jpeg|png|webp)\z}
  end

  def size_range
    1.byte..5.megabytes
  end
end
