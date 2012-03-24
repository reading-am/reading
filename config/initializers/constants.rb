SHORT_DOMAIN = 'ing.am'
BOOKMARKLET_VERSION = '1.0.1'

case Rails.env
when 'production'
  DOMAIN = 'reading.am'
when 'staging'
  DOMAIN = 'staging.reading.am'
when 'development'
  DOMAIN = '0.0.0.0:3000'
end
