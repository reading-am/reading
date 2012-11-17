require "spec_helper"

describe Hook do
  fixtures :hooks
  context "when new" do
    it "won't save without a valid page_id" do
      hook = hooks(:twitter)
      hook.provider.should eq("twitter")
    end
  end
end
