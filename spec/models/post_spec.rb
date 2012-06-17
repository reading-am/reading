require "spec_helper"

describe Post do
  context "when new" do
    it "won't save without a valid page_id" do
      post = Post.create
      post.should be_an_instance_of Post
    end
  end
end
