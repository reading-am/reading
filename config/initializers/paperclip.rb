# NOTE :path taken from https://github.com/thoughtbot/paperclip/blob/master/lib/paperclip/attachment.rb#L27
# For some reason it's required to specify :path when using :s3_alias_url as the :url
Paperclip::Attachment.default_options.merge!(
  :storage => :s3,
  :s3_protocol => 'https',
  :url => ":s3_alias_url",
  :path => ":class/:attachment/:id_partition/:style/:filename",
  :bucket => ENV['READING_S3_BUCKET'],
  :s3_host_alias => ENV['READING_S3_BUCKET'],
  :s3_credentials => {
    :access_key_id => ENV['READING_S3_KEY'],
    :secret_access_key => ENV['READING_S3_SECRET']
  }
)
