require "spec_helper"

RSpec.describe "railtie" do
  it "does not raise error on #require" do
    action = -> {
      require "rails"
      require "active_uuid/railtie"
    }
    expect(action).to_not raise_error
  end
end
