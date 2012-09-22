SHORT_DOMAIN = 'ing.am'
BOOKMARKLET_VERSION = '1.0.1'

case Rails.env
when 'staging'
  DOMAIN = 'staging.reading.am'
when 'development'
  DOMAIN = '0.0.0.0:3000'
else
  DOMAIN = 'reading.am'
  #DOMAIN = '0.0.0.0:3000' # for testing
end

AMAZON_ASSOC_ID = 'reading048-20'
