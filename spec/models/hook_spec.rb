require "spec_helper"

describe Hook do
  fixtures :hooks, :posts, :pages, :domains, :authorizations

  context "when run" do

    it "posts to Twitter" do
      # setup
      hook = hooks(:twitter)
      hook.authorization = authorizations(:twitter)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, :new)
      response.should be_an_instance_of Twitter::Tweet
      #cleanup
      hook.authorization.api.status_destroy(response.id)
    end

    it "posts to Tumblr" do
      # setup
      hook = hooks(:tumblr)
      hook.authorization = authorizations(:tumblr)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, :new)
      response.should be_an_instance_of Twitter::Tweet
      #cleanup
      hook.authorization.api.status_destroy(response.id)
    end

  end

end
