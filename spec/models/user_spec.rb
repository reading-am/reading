require "rails_helper"

describe User do
  fixtures :users

  context "when new" do
    it "won't save without a valid page_id" do
    end
  end

  context "when created", commit: true do
    it "sends a pusher notice", commit: true do
      user = User.create username: 'tester', email: 'greg@example.com', password: 'thisisatestpass'
      expect(PusherJob).to have_been_enqueued.once.with('create', user)
    end

    it "sends a welcome email", commit: true do
      user = User.create username: 'tester', email: 'greg@example.com', password: 'thisisatestpass'
      expect(ActionMailer::DeliveryJob).to have_been_enqueued.once.with('UserMailer', 'welcome', 'deliver_now', user)
    end
  end

  context "when updated" do
    it "sends a pusher notice", commit: true do
      user = users(:greg)
      user.update username: 'a_new_username'
      expect(PusherJob).to have_been_enqueued.once.with('update', user)
    end

    it "sends a welcome email if username or email was previously missing", commit: true do
      user = User.create username: 'tester', password: 'thisisatestpass'
      expect(ActionMailer::DeliveryJob).to_not have_been_enqueued
      user.update email: 'greg@example.com'
      expect(ActionMailer::DeliveryJob).to have_been_enqueued.once.with('UserMailer', 'welcome', 'deliver_now', user)
    end
  end

  context "when destroyed" do
    it "sends a pusher notice" do
      user = users(:greg)
      user.destroy
      expect(PusherJob).to have_been_enqueued.once.with('destroy', user)
    end
  end
end
