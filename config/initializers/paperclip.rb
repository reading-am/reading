Paperclip::Attachment.default_options.merge!(
  storage: :s3,
  s3_protocol: 'https',
  bucket: ENV['S3_BUCKET'],
  s3_region: ENV['S3_REGION'],
  s3_host_alias: ENV['S3_BUCKET'],
  s3_credentials: {
    access_key_id: ENV['S3_KEY'],
    secret_access_key: ENV['S3_SECRET']
  }
)

########################
# To switch to a CNAME #
# add the params below #
########################
# Before doing so, see: https://github.com/leppert/reading/issues/339
# NOTE :path taken from https://github.com/thoughtbot/paperclip/blob/master/lib/paperclip/attachment.rb#L27
# For some reason it's required to specify :path when using :s3_alias_url as the :url
#:url => ":s3_alias_url",
#:path => ":class/:attachment/:id_partition/:style/:filename",
