require "spec_helper"

describe Hook do
  fixtures :hooks, :posts, :pages, :domains, :authorizations
  context "when run" do
    it "posts to Twitter" do
      hook = hooks(:twitter)
      hook.authorization = authorizations(:twitter)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)

      hook.run(post, :new).should be_an_instance_of Twitter::Tweet
    end
  end
end
