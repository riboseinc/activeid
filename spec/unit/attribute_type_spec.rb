require "spec_helper"

# Type assertions are necessary because you can't tell UUID and String apart
# with regular ==.
RSpec.describe ActiveUUID::AttributeType do
  let(:uuid) { UUIDTools::UUID.parse(hex_with_dashes) }
  let(:hex_with_dashes) { "472b22d4-9fa3-45c4-86cd-2f2cdf77d485" }
  let(:hex_without_dashes) { hex_with_dashes.delete("-").upcase }
  let(:binary_string) { uuid.raw }

  describe ActiveUUID::AttributeType::BinaryUUID do
    let(:instance) { described_class.new }

    describe "#cast" do
      subject { instance.method(:cast) }
      example { expect(subject.(uuid)).to be_respective_uuid }
      example { expect(subject.(hex_with_dashes)).to be_respective_uuid }
      example { expect(subject.(hex_without_dashes)).to be_respective_uuid }
      example { expect(subject.(nil)).to be(nil) }
    end

    describe "#serialize" do
      subject { instance.method(:serialize) }
      example { expect(subject.(uuid)).to be_respective_binary }
      example { expect(subject.(nil)).to be(nil) }
    end

    describe "#deserialize" do
      subject { instance.method(:deserialize) }
      example { expect(subject.(binary_string)).to be_respective_uuid }
      example { expect(subject.(nil)).to be(nil) }
    end
  end

  describe ActiveUUID::AttributeType::StringUUID do
    let(:instance) { described_class.new }

    describe "#cast" do
      subject { instance.method(:cast) }
      example { expect(subject.(uuid)).to be_respective_uuid }
      example { expect(subject.(hex_with_dashes)).to be_respective_uuid }
      example { expect(subject.(hex_without_dashes)).to be_respective_uuid }
      example { expect(subject.(nil)).to be(nil) }
    end

    describe "#serialize" do
      subject { instance.method(:serialize) }
      example { expect(subject.(uuid)).to be_respective_uuid_string }
      example { expect(subject.(nil)).to be(nil) }
    end

    describe "#deserialize" do
      subject { instance.method(:deserialize) }
      example { expect(subject.(binary_string)).to be_respective_uuid }
      example { expect(subject.(nil)).to be(nil) }
    end
  end

  def be_respective_uuid
    eq(uuid) & be_instance_of(UUIDTools::UUID)
  end

  def be_respective_binary
    eq(binary_string) & be_instance_of(::ActiveRecord::Type::Binary::Data)
  end

  def be_respective_uuid_string
    eq(hex_with_dashes) & be_instance_of(String)
  end
end
