# NOTE - this file is prefixed with 01 so that it loads first
# via: http://stackoverflow.com/questions/4779773/how-do-i-change-the-load-order-of-initializers-in-rails-3

SHORT_DOMAIN = 'ing.am'
BOOKMARKLET_VERSION = '1.0.1'

case Rails.env
when 'staging'
  DOMAIN = 'staging.reading.am'
  S3_BUCKET = 'media.staging.reading.am'
when 'development', 'test'
  DOMAIN = '0.0.0.0:3000'
  S3_BUCKET = 'media.development.reading.am'
else
  DOMAIN = 'reading.am'
  S3_BUCKET = 'media.reading.am'
  #DOMAIN = '0.0.0.0:3000' # for testing
end

AMAZON_ASSOC_ID = 'reading048-20'
