class Doorkeeper::Application
  def simple_obj
    {
      type: 'OauthApp',
      name: name
    }
  end
end
