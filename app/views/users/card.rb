module Users
  class Card < ::Stache::Mustache::View

    def is_current_user
      user == current_user
    end

    def follow_text
      current_user.following?(user) ? 'unfollow' : 'follow'
    end

    def follow_text_capitalized
      follow_text.capitalize
    end

  end
end
