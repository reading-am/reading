class Doorkeeper::Application
  def simple_obj
    {
      type: 'OauthApp',
      name: name
    }
  end
end

class Doorkeeper::AccessToken
  belongs_to :user, foreign_key: :resource_owner_id

  def simple_obj
    {
      type: 'OauthAccessToken',
      token: token,
      app: application.simple_obj
    }
  end
end
