# Don't resize the images when testing uploading pictures.

if Rails.env.test?
  CarrierWave.configure do |config|
    config.enable_processing = false
  end
end
