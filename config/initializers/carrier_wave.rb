if Rails.env.production?
  # Configuration for Amazon Web Services (AWS) Simple Storage Service (S3).
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      :provider              => 'AWS',
      :aws_access_key_id     => 'Access Key Here',
      :aws_secret_access_key => 'Secret Key Here',
      :use_iam_profile       => false, # Warning messages and very slow if true.
      :region                => 'us-east-2'
    }
    config.fog_directory     =  'Bucket Name Here'
    config.fog_public        = false # True doesn't work without public bucket.
  end
end
