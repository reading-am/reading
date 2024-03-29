class Doorkeeper::Application
  has_attached_file :icon,
    :styles => {
      :mini => "25x25>",
      :thumb => "70x70>",
      :medium => "140x140>",
      :large => "500x500>"
    },
    :default_url => "#{ROOT_URL}/assets/oauth_apps/:attachment/default/:style.png"

  validates_attachment :icon,
    :size => { :less_than => 2.megabytes },
    :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  def icon_url style=:original
    # URL generation through the paperclip gem is slooowwwww. This is a swifter workaround.
    # https://github.com/thoughtbot/paperclip/issues/909
    base = "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/oauth_apps/icons"
    if icon_file_name.blank?
      "#{base}/default/#{style}.png"
    else
      "#{base}/#{sprintf('%09d', id).gsub(/(\d{3})(?=\d)/, '\\1/')}/#{style}/#{icon_file_name}?#{icon_updated_at.to_time.to_i}"
    end
  end
end

class Doorkeeper::AccessToken
  belongs_to :user, foreign_key: :resource_owner_id
end
