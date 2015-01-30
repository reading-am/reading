require "rails_helper"

describe Hook do
  fixtures :users, :hooks, :domains, :pages, :posts, :authorizations

  context "when run" do

    pending "posts to Facebook"

    it "posts to Twitter" do
      # setup
      hook = hooks(:twitter)
      hook.authorization = authorizations(:twitter)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response).to be_an_instance_of Twitter::Tweet
      # cleanup
      response = hook.authorization.api.status_destroy(response.id)
      expect(response.first).to be_an_instance_of Twitter::Tweet
    end

    it "posts to Tumblr" do
      # setup
      hook = hooks(:tumblr)
      hook.authorization = authorizations(:tumblr)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.meta.status).to eq(201)
      # cleanup
      response = hook.authorization.api.delete_post("#{hook.place[:id]}.tumblr.com", response.response.id)
      expect(response.meta.status).to eq(200)
    end

    it "posts to Evernote" do
      # setup
      hook = hooks(:evernote)
      hook.authorization = authorizations(:evernote)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response).to be_an_instance_of Evernote::EDAM::Type::Note
      # cleanup
      # NOTE - our api key is "Basic access" and doesn't
      # allow note updating or deleting so there is no cleanup
    end

    it "posts to Readability" do
      # setup
      hook = hooks(:readability)
      hook.authorization = authorizations(:readability)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.status).to eq("202")
      # cleanup
      response = hook.authorization.api.delete_bookmark response.bookmark_id
      expect(response.status).to eq("204")
    end

    it "posts to Instapaper" do
      # setup
      hook = hooks(:instapaper)
      hook.authorization = authorizations(:instapaper)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.bookmark_id).to be_an_instance_of(Fixnum)
      # cleanup
      # NOTE - deleting bookmarks would require a $1/mo
      # Instapaper subscription
    end

    it "posts to Pocket" do
      # setup
      hook = hooks(:pocket)
      hook.authorization = authorizations(:pocket)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.code).to eq(200)
      # cleanup
      body = ActiveSupport::JSON.decode response.body
      response = Typhoeus::Request.post 'https://getpocket.com/v3/send',
        :params => {
          :consumer_key => ENV['READING_POCKET_KEY'],
          :access_token => hook.authorization.token,
          :actions => [{
            :action => 'delete',
            :item_id => body["item"]["item_id"]
          }].to_json
        }
      expect(response.code).to eq(200)
    end

    it "posts to Kippt" do
      # setup
      hook = hooks(:kippt)
      hook.authorization = authorizations(:kippt)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.id).to be_an_instance_of(Fixnum)
      # cleanup
      response = response.destroy
      expect(response).to be true
    end

    it "posts to HipChat" do
      # setup
      hook = hooks(:hipchat)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      post.user = users(:greg)
      # test
      response = hook.run(post, 'new')
      expect(response).to be true
      # cleanup
      # NOTE - It's a chat client so there is no cleanup
    end

    it "posts to Campfire" do
      # setup
      hook = hooks(:tssignals)
      hook.authorization = authorizations(:tssignals)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.message.type).to eq("TextMessage")
      expect(response.message.id).to be_an_instance_of(Fixnum)
      # cleanup
      # NOTE - It's a chat client so there is no cleanup
    end

    it "posts to Pinboard" do
      # setup
      hook = hooks(:pinboard)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      response = hook.run(post, 'new')
      expect(response.code).to eq(200)
      # cleanup
      response = Typhoeus::Request.get 'https://api.pinboard.in/v1/posts/delete',
        :params => {
          :auth_token => "#{hook.params['user']}:#{hook.params['token']}",
          :url => post.page.url
        }
      expect(response.code).to eq(200)
    end

    it "posts to Flattr" do
      # setup
      hook = hooks(:flattr)
      hook.authorization = authorizations(:flattr)
      post = posts(:one)
      post.page = pages(:daringfireball)
      post.page.domain = domains(:daringfireball)
      # test
      # NOTE - it's kind of screwy that we want this to throw an error
      # but I don't know of a better way to test it without adding funds
      # to flattr.com. A funds error at least means we made a round trip
      begin
        hook.run(post, 'new')
        raise Flattr::Error::BadRequest.new
      rescue Flattr::Error::Unauthorized => e
        expect(e.message).to eq("You don't have any money to flattr with")
      end
    end

  end

end
