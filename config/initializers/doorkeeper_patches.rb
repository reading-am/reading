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
    base = "https://s3.amazonaws.com/#{ENV['READING_S3_BUCKET']}/oauth_apps/icons"
    if icon_file_name.blank?
      "#{base}/default/#{style}.png"
    else
      "#{base}/#{sprintf('%09d', id).gsub(/(\d{3})(?=\d)/, '\\1/')}/#{style}/#{icon_file_name}?#{icon_updated_at.to_time.to_i}"
    end
  end

  def simple_obj
    {
      type: 'OauthApp',
      consumer_key: uid,
      name: name,
      description: description,
      website: website,
      redirect_uri: redirect_uri,
      app_store_url:  app_store_url,
      play_store_url: play_store_url,
      icon_medium:   icon_url(:medium),
      icon_thumb:    icon_url(:thumb),
      icon_mini:     icon_url(:mini),
      created_at:    created_at,
      updated_at:    updated_at
    }
  end
end

class Doorkeeper::AccessToken
  belongs_to :user, foreign_key: :resource_owner_id

  def simple_obj
    {
      type: 'OauthAccessToken',
      token: token,
      app: application.simple_obj,
      created_at: created_at,
      scopes: scopes
    }
  end
end
