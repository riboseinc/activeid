require "active_record"

module ActiveUUID
  # A data type to be used with ActiveRecord.
  #
  # See docs for +::ActiveRecord::Attributes::ClassMethods#attribute+ for usage.
  # See docs for +::ActiveRecord::Type::Value+ for meaning of overriden methods.
  class AttributeType < ::ActiveRecord::Type::Value
    attr_reader :storage_type

    delegate :cast_to_uuid, to: ActiveUUID::Utils
    delegate :serialize, :deserialize, to: :storage_type, prefix: :s

    def initialize(storage_mode)
      @storage_type = instantiate_storage(storage_mode)
    end

    # Converts UUID or its string representation into a binary value (see
    # super).
    def serialize(value)
      s_serialize(cast_to_uuid(value))
    end

    # Converts binary values into UUIDs.
    def deserialize(value)
      cast_to_uuid(s_deserialize(value))
    end

    # Converts strings into UUIDs on user input assignment, called internally
    # from #cast.
    def cast_value(value)
      cast_to_uuid(value)
    end

    private

    # Returns a new instance of attribute type appropriate for requested storage
    # mode.
    def instantiate_storage(storage_mode)
      case storage_mode
      when :binary then BinaryStorage.new
      when :string then StringStorage.new
      else
        raise ArgumentError, "Incorrect storage mode.  It must be " +
          "either :binary or :string, but #{storage_mode.inspect} was passed."
      end
    end

    # Wrapper for `ActiveRecord::Type::Binary` which (de)serializes UUIDs.
    class BinaryStorage < ::ActiveRecord::Type::Binary
      def serialize(uuid_or_nil)
        super(uuid_or_nil&.raw)
      end
    end

    # Wrapper for `ActiveModel::Type::String` which (de)serializes UUIDs.
    class StringStorage < ActiveRecord::Type::String
      def serialize(uuid_or_nil)
        super(uuid_or_nil&.to_s)
      end
    end
  end
end
