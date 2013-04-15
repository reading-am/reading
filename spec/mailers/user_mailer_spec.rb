require "spec_helper"

describe UserMailer do
  fixtures :users, :comments, :pages

  it "should deliver new follower mail" do
    UserMailer.new_follower(users(:greg), users(:howard)).deliver
  end

  it "should deliver mentioned mail" do
    comment = comments(:single_mention)
    comment.user = users(:howard)
    comment.page = pages(:daringfireball)

    UserMailer.mentioned(comment, users(:greg)).deliver
  end

  it "should deliver shown a page mail" do
    comment = comments(:single_show)
    comment.user = users(:howard)
    comment.page = pages(:daringfireball)

    UserMailer.shown_a_page(comment, users(:greg)).deliver
  end

  it "should deliver comments welcome mail" do
    comment = comments(:single_show)
    comment.user = users(:howard)

    UserMailer.comments_welcome(users(:greg), comment).deliver
  end

  it "should deliver welcome mail" do
    UserMailer.welcome(users(:greg)).deliver
  end

  it "should deliver destroyed mail" do
    UserMailer.destroyed(users(:greg)).deliver
  end

  it "should deliver digest mail" do
    UserMailer.digest(users(:greg)).deliver
  end

end
