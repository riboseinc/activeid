require "spec_helper"

RSpec.shared_examples "model with UUIDs" do
  let!(:article) { Fabricate model.name.underscore }
  let!(:id) { article.id }
  subject { model }

  context "model" do
    its(:primary_key) { is_expected.to eq("id") }
    its(:all) { is_expected.to eq([article]) }
    its(:first) { is_expected.to eq(article) }
  end

  context "existance" do
    subject { article }
    its(:id) { is_expected.to be_a UUIDTools::UUID }
  end

  context "interpolation" do
    specify { model.where("id = :id", id: quoted_article_id) }
  end

  context "batch interpolation" do
    before { model.update_all(["title = CASE WHEN id = :id THEN 'Passed' ELSE 'Nothing' END", id: quoted_article_id]) }
    specify { expect(article.reload.title).to eq("Passed") }
  end

  context ".find" do
    specify { expect(model.find(article.id)).to eq(article) }
    specify { expect(model.find(id)).to eq(article) }
    specify { expect(model.find(id.to_s)).to eq(article) }
    specify { expect(model.find(id.raw)).to eq(article) }
  end

  context ".where" do
    specify { expect(model.where(id: article).first).to eq(article) }
    specify { expect(model.where(id: id).first).to eq(article) }
    specify { expect(model.where(id: id.to_s).first).to eq(article) }
    specify { expect(model.where(id: id.raw).first).to eq(article) }
  end

  context "#destroy" do
    subject { article }
    its(:delete) { is_expected.to be_truthy }
    its(:destroy) { is_expected.to be_truthy }
  end

  context "#reload" do
    subject { article }
    its(:'reload.id') { is_expected.to eq(id) }
    specify { expect(subject.reload(select: :another_uuid).id).to eq(id) }
  end

  shared_examples "for UUID attribute" do
    let(:attr_type) { model.attribute_types[attr_name.to_s] }
    let(:attr_getter) { article.method(attr_name) }
    let(:attr_setter) { article.method("#{attr_name}=") }

    let(:uuid) { UUIDTools::UUID.random_create }

    it "has proper ActiveRecord type" do
      expect(attr_type).to be_kind_of(ActiveUUID::AttributeType)
    end

    it "allows to assign UUID instance" do
      attr_setter.(uuid)
      expect(attr_getter.()).to be_an(UUIDTools::UUID) & eq(uuid)
    end

    it "allows to assign UUID string" do
      attr_setter.(uuid.to_s)
      expect(attr_getter.()).to be_an(UUIDTools::UUID) & eq(uuid)
    end

    it "persists UUID in database" do
      attr_setter.(uuid)
      article.save
      article.reload
      expect(attr_getter.()).to be_an(UUIDTools::UUID) & eq(uuid)
    end
  end

  describe "UUID attribute which is a model's primary key" do
    let(:attr_name) { :id }
    include_examples "for UUID attribute"
  end

  describe "UUID attribute which isn't a model's primary key" do
    let(:attr_name) { :another_uuid }
    include_examples "for UUID attribute"
  end
end
