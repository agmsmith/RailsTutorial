if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => 'Access Key Here',
      :aws_secret_access_key => 'Secret Key Here'
    }
    config.fog_directory     =  'Bucket Name Here'
    # May also need:  config.fog_provider = 'fog/aws'
  end
end
