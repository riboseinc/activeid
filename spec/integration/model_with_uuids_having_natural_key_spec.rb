require "spec_helper"

describe UuidArticleWithNaturalKey do
  let!(:article) { Fabricate :uuid_article_with_natural_key }
  let!(:id) { article.id }
  let!(:uuid) { UUIDTools::UUID.sha1_create(UUIDTools::UUID_OID_NAMESPACE, article.title) }
  subject { article }
  context "natural_key" do
    its(:id) { should == uuid }
  end
end
