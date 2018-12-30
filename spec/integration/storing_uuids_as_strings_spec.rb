require "spec_helper"

Dir["#{__dir__}/examples_*.rb"].each { |f| require f }

RSpec.describe "storing simple UUIDs as strings" do
  include_examples "model with UUIDs" do
    let(:model) { StringUuidArticle }
    let(:quoted_article_id) { article.id.to_s }
  end
end

RSpec.describe "storing UUIDs with a natural key as strings" do
  include_examples "model with UUIDs and a natural key" do
    let(:model) { StringUuidArticleWithNaturalKey }
  end
end

RSpec.describe "storing UUIDs with a namespace as strings" do
  include_examples "model with UUIDs and a namespace" do
    let(:model) { StringUuidArticleWithNamespace }
  end
end
