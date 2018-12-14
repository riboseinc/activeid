require "spec_helper"

describe UuidArticleWithNamespace do
  let!(:article) { Fabricate :uuid_article_with_namespace }
  let!(:id) { article.id }
  let!(:namespace) { UuidArticleWithNamespace._uuid_namespace }
  let!(:uuid) { UUIDTools::UUID.sha1_create(namespace, article.title) }
  subject { article }
  context "natural_key_with_namespace" do
    its(:id) { should == uuid }
  end
end
