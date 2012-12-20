require "spec_helper"

describe Comment do
  fixtures :comments

  context "when body contains only mentions and whitespace or commas" do
    it "should be recognized as a 'show'" do
      comment = comments(:single_show)
      comment.is_a_show.should be_true

      comment = comments(:multiple_show)
      comment.is_a_show.should be_true
    end
  end
end
