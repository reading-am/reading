require "rails_helper"

describe Hook do
  fixtures :users, :authorizations, :hooks, :domains, :pages, :posts

  context "when run" do

    pending "posts to Facebook"

    it "posts to Twitter" do
      # setup
      hook = hooks(:twitter)
      post = posts(:one)
      # test
      response = hook.twitter(post, 'new')
      expect(response).to be_an_instance_of Twitter::Tweet
      # cleanup
      response = hook.authorization.api.destroy_status(response.id)
      expect(response.first).to be_an_instance_of Twitter::Tweet
    end

    it "posts to Tumblr" do
      # setup
      hook = hooks(:tumblr)
      post = posts(:one)
      # test
      response = hook.tumblr(post, 'new')
      expect(response.meta.status).to eq(201)
      # cleanup
      response = hook.authorization.api.delete_post("#{hook.place[:id]}.tumblr.com", response.response.id)
      expect(response.meta.status).to eq(200)
    end

    it "posts to Evernote" do
      # setup
      hook = hooks(:evernote)
      post = posts(:one)
      # test
      response = hook.evernote(post, 'new')
      expect(response).to be_an_instance_of Evernote::EDAM::Type::Note
      # cleanup
      # NOTE - our api key is "Basic access" and doesn't
      # allow note updating or deleting so there is no cleanup
    end

    it "posts to Readability" do
      # setup
      hook = hooks(:readability)
      post = posts(:one)
      # test
      response = hook.readability(post, 'new')
      expect(response.status).to eq("202")
      # cleanup
      response = hook.authorization.api.delete_bookmark response.bookmark_id
      expect(response.status).to eq("204")
    end

    it "posts to Instapaper" do
      # setup
      hook = hooks(:instapaper)
      post = posts(:one)
      # test
      response = hook.instapaper(post, 'new')
      expect(response.bookmark_id).to be_an_instance_of(Fixnum)
      # cleanup
      # NOTE - deleting bookmarks would require a $1/mo
      # Instapaper subscription
    end

    it "posts to Pocket" do
      # setup
      hook = hooks(:pocket)
      post = posts(:one)
      # test
      response = hook.pocket(post, 'new')
      expect(response.code).to eq(200)
      # cleanup
      body = ActiveSupport::JSON.decode response.body
      response = Typhoeus::Request.post(
        'https://getpocket.com/v3/send',
        params: { consumer_key: ENV['POCKET_KEY'],
                  access_token: hook.authorization.token,
                  actions: [{ action: 'delete',
                              item_id: body['item']['item_id'] }].to_json }
      )
      expect(response.code).to eq(200)
    end

    it "posts to HipChat" do
      # setup
      hook = hooks(:hipchat)
      post = posts(:one)
      # test
      response = hook.hipchat(post, 'new')
      expect(response).to be true
      # cleanup
      # NOTE - It's a chat client so there is no cleanup
    end

    it "posts to Pinboard" do
      # setup
      hook = hooks(:pinboard)
      post = posts(:one)
      # test
      response = hook.pinboard(post, 'new')
      expect(response.code).to eq(200)
      # cleanup
      response = Typhoeus::Request.get 'https://api.pinboard.in/v1/posts/delete',
        params: {
          auth_token: "#{hook.params['user']}:#{hook.params['token']}",
          url: post.page.url
        }
      expect(response.code).to eq(200)
    end

    # The service is currently down
    # it "posts to Flattr" do
    #   # setup
    #   hook = hooks(:flattr)
    #   post = posts(:three)
    #   # test
    #   response = hook.flattr(post, 'new')
    #   expect(response).to be true
    # end

    it "posts to Slack" do
      # setup
      hook = hooks(:slack)
      post = posts(:one)
      # test
      response = hook.slack(post, 'new')
      expect(response).to be_an_instance_of Slack::Messages::Message
      expect(response['ok']).to be true
      # cleanup
      # NOTE - It's a chat client so there is no cleanup
    end
  end
end
