require "spec_helper"

Dir["#{__dir__}/examples_*.rb"].each { |f| require f }

describe "storing simple UUIDs as binaries" do
  include_examples "model with UUIDs" do
    let(:model) { BinaryUuidArticle }
    let(:quoted_article_id) { ActiveUUID.quote_as_binary(article.id) }
  end
end

describe "storing UUIDs with a natural key as binaries" do
  include_examples "model with UUIDs and a natural key" do
    let(:model) { BinaryUuidArticleWithNaturalKey }
  end
end

describe "storing UUIDs with a namespace as binaries" do
  include_examples "model with UUIDs and a namespace" do
    let(:model) { BinaryUuidArticleWithNamespace }
  end
end
