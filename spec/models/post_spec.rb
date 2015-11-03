require "rails_helper"

describe Post do
  fixtures :users, :hooks, :domains, :pages, :posts

  context "when new" do
    it "won't save without a valid page_id" do
    end
  end

  context "when created", commit: true do
    it "executes the user's hooks", commit: true do
      user = users(:greg)
      expect(user.hooks.count).to be > 1
      post = Post.create user: user, page: pages(:daringfireball)
      expect(HookJob).to have_been_enqueued
                          .times(user.hooks.count)
                          .with(global_id(user.hooks.first),
                                global_id(post),
                                'new')
    end

    it "sends a pusher notice", commit: true do
      post = Post.create user: users(:greg), page: pages(:daringfireball)
      expect(PusherJob).to have_been_enqueued.once.with('create', global_id(post))
    end
  end

  context "when updated" do
    it "executes the user's hooks", commit: true do
      post = posts(:one)
      user = post.user
      hooks = user.hooks.select { |hook| hook.responds_to(:yep) }

      post.update yn: true
      expect(HookJob).to have_been_enqueued
                          .times(hooks.length)
                          .with(global_id(hooks.first),
                                global_id(post),
                                'yep')
    end

    it "sends a pusher notice", commit: true do
      post = posts(:one)
      post.update yn: !post.yn
      expect(PusherJob).to have_been_enqueued.once.with('update', global_id(post))
    end
  end

  context "when destroyed" do
    it "sends a pusher notice", commit: true do
      post = posts(:one)
      post.destroy
      expect(PusherJob).to have_been_enqueued.once.with('destroy', global_id(post))
    end
  end
end
