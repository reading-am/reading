require "spec_helper"

describe Comment do
  fixtures :comments

  context "when body contains only mentions and whitespace or commas" do
    it "should be recognized as a single 'show'" do
      comment = comments(:single_show)
      comment.is_a_show.should be_true
    end

    it "should be recognized as a multiple 'show'" do
      comment = comments(:multiple_show)
      comment.is_a_show.should be_true
    end
  end

  context "when body contains emails " do
    it "should recognize a single email address" do
      comment = comments(:single_email)
      comment.mentioned_emails[0].should eq(comment.body)
    end

    it "should recognize multiple email addresses" do
      emails = ["greg@reading.am","test@example.com","heyo@fun.vg"]
      comment = Comment.new :body => "This is an email for #{emails[0]} and #{emails[1]},#{emails[2]}"
      (comment.mentioned_emails - emails).should eq([])
    end
  end
end
