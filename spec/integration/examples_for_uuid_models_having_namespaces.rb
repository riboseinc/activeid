require "spec_helper"

shared_examples "model with UUIDs and a namespace" do
  let!(:article) { Fabricate model.name.underscore }
  let!(:id) { article.id }
  let!(:namespace) { model._uuid_namespace }
  let!(:uuid) { UUIDTools::UUID.sha1_create(namespace, article.title) }
  subject { article }
  context "natural_key_with_namespace" do
    its(:id) { should == uuid }
  end
end
