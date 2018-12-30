require "spec_helper"

RSpec.shared_examples "model with UUIDs and a namespace" do
  let!(:article) { Fabricate model.name.underscore }
  let!(:id) { article.id }
  let!(:namespace) { model._uuid_namespace }
  let!(:uuid) { UUIDTools::UUID.sha1_create(namespace, article.title) }
  subject { article }
  context "natural_key_with_namespace" do
    its(:id) { is_expected.to eq(uuid) }
  end
end
