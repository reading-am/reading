CarrierWave.configure do |config|
  config.cache_dir = "#{Rails.root}/tmp/"
  config.storage = :fog
  config.permissions = 0666
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['READING_S3_KEY'],
    :aws_secret_access_key  => ENV['READING_S3_SECRET'],
  }
  config.fog_directory = ENV['READING_S3_BUCKET']
end
