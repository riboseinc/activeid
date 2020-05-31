require "spec_helper"

RSpec.describe ActiveID::Utils do
  let(:uuid) { UUIDTools::UUID.parse hex_with_dashes }
  let(:hex_with_dashes) { "472b22d4-9fa3-45c4-86cd-2f2cdf77d485" }
  let(:hex_without_dashes) { hex_with_dashes.delete("-").upcase }
  let(:binary_string) { uuid.raw }

  describe "#cast_to_uuid" do
    subject { described_class.method(:cast_to_uuid) }

    it "returns argument itself when UUID instance is given" do
      expect(subject.(uuid)).to be(uuid)
    end

    it "returns argument itself when nil is given" do
      expect(subject.(nil)).to be(nil)
    end

    it "returns respective UUID instance when 16 bytes long binary string is " +
      "given" do
      expect(binary_string.size).to eq(16)
      expect(subject.(binary_string)).to eq(uuid)
    end

    it "returns respective UUID instance when string consisting of " +
      "32 hexadecimal digits and 4 dashes is given" do
      expect(hex_with_dashes.size).to eq(32 + 4)
      expect(subject.(hex_with_dashes)).to eq(uuid)
      expect(subject.(hex_with_dashes.swapcase)).to eq(uuid)
    end

    it "returns respective UUID instance when string consisting of " +
      "32 hexadecimal digits without dashes is given" do
      expect(hex_with_dashes.size).to eq(32 + 4)
      expect(subject.(hex_without_dashes)).to eq(uuid)
      expect(subject.(hex_without_dashes.swapcase)).to eq(uuid)
    end

    it "raises an ArgumentError when given sting is neither a 16 bytes long " +
      "binary string nor representation of 32 digits long hexadecimal number" do

      pending "UUIDTools::UUID is bit too liberal, and sometimes accepts " +
        "malformed input."

      malformed_uuid_strings = [
        "",
        binary_string[0..-2],
        hex_with_dashes.tr("abcdef", "x"),
        hex_with_dashes.tr("-", "="),
        hex_with_dashes[0..-2],
        hex_with_dashes + "a",
        hex_without_dashes.tr("abcdef", "x"),
        hex_without_dashes[0..-2],
        hex_without_dashes + "a",
      ]

      malformed_uuid_strings.each do |s|
        expect { subject.(s) }.to(
          raise_error(ArgumentError, /16, 32, or 36/),
          "tested string was: #{s.inspect}"
        )
      end
    end

    it "raises an ArgumentError when argument is neither UUID, nil, " +
      "nor string" do
      expect { subject.(3) }.to raise_error(ArgumentError)
      expect { subject.([hex_with_dashes]) }.to raise_error(ArgumentError)
    end
  end

  describe "#quote_as_binary" do
    subject { described_class.method(:quote_as_binary) }

    it "returns nil for nil" do
      expect(subject.(nil)).to be(nil)
    end

    it "returns binary data for UUID instance" do
      expect(subject.(uuid)).to be_a_binary_data_containing_uuid
    end

    it "returns binary data for UUID string" do
      expect(subject.(hex_with_dashes)).to be_a_binary_data_containing_uuid
      expect(subject.(hex_without_dashes)).to be_a_binary_data_containing_uuid
    end

    it "is also available (delegates) in ActiveID top-level module" do
      expect(ActiveID).to respond_to(:quote_as_binary)
    end

    def be_a_binary_data_containing_uuid
      be_a(::ActiveRecord::Type::Binary::Data) & eq(binary_string)
    end
  end
end
