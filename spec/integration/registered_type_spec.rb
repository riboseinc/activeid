require "spec_helper"

Dir["#{__dir__}/examples_*.rb"].each { |f| require f }

RSpec.describe "using registered :uuid type" do
  before do
    if ENV.fetch("NO_PATCHES", false)
      skip "Attribute types are not registered when monkey patching is disabled"
    end
  end

  include_examples "model with UUIDs" do
    let(:model) { RegisteredUuidTypeArticle }

    unless ENV["DB"] == "postgresql"
      let(:quoted_article_id) { ActiveUUID.quote_as_binary(article.id) }
    end
  end
end
