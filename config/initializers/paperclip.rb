# to remain compatible with version 2.x
# via: http://stackoverflow.com/questions/10325288/paperclip-change-images-path-after-upgrade-to-rails-3-2
Paperclip::Attachment.default_options.merge!(
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
  :url => "/system/:attachment/:id/:style/:basename.:extension"
)
