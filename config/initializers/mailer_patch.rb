# This is a monkey patch because, when upgrading to Rails 4,
# rspec calls params() on the UserMailer object if there's a
# stylesheet_link_tag in any of the html templates.
# This method doesn't exist so the tests fail.
# TODO - upgrade rails and/or rspec in a few weeks and see if this is fixed
#
# This was also rearing its head in productin on the password
# reset form so that's why we're patching ActionMailer directly

class ActionMailer::Base
  def params; {}; end
end
