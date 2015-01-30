require "rails_helper"

describe Comment do
  fixtures :comments

  context "when body contains only mentions and whitespace or commas" do
    it "should be recognized as a single 'show'" do
      comment = comments(:single_show)
      expect(comment.is_a_show).to be true
    end

    it "should be recognized as a multiple 'show'" do
      comment = comments(:multiple_show)
      expect(comment.is_a_show).to be true
    end
  end

  context "when body contains emails " do
    it "should recognize a single email address" do
      comment = comments(:single_email)
      expect(comment.mentioned_emails[0]).to eq(comment.body)
    end

    it "should recognize multiple email addresses" do
      emails = ["greg@reading.am","test@example.com","heyo@fun.vg"]
      comment = Comment.new :body => "This is an email for #{emails[0]} and #{emails[1]},#{emails[2]}"
      expect(comment.mentioned_emails - emails).to eq([])
    end
  end
end
