require "spec_helper"

shared_examples "model with UUIDs and a natural key" do
  let!(:article) { Fabricate model.name.underscore }
  let!(:id) { article.id }
  let!(:uuid) { UUIDTools::UUID.sha1_create(UUIDTools::UUID_OID_NAMESPACE, article.title) }
  subject { article }
  context "natural_key" do
    its(:id) { should == uuid }
  end
end
