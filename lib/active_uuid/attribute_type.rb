require "active_record"

module ActiveUUID
  # A data type to be used with ActiveRecord.
  #
  # See docs for +::ActiveRecord::Attributes::ClassMethods#attribute+ for usage.
  # See docs for +::ActiveRecord::Type::Value+ for meaning of overriden methods.
  module AttributeType
    class Base < ::ActiveRecord::Type::Value
      attr_reader :storage_type

      delegate :cast_to_uuid, to: ActiveUUID::Utils
      delegate :serialize, :deserialize, to: :storage_type, prefix: :s

      def initialize
        @storage_type = instantiate_storage
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
    end

    class BinaryUUID < Base
      def instantiate_storage
        ::ActiveRecord::Type::Binary.new
      end

      def serialize(value)
        s_serialize(cast_to_uuid(value)&.raw)
      end
    end

    class StringUUID < Base
      def instantiate_storage
        ::ActiveRecord::Type::String.new
      end

      def serialize(value)
        s_serialize(cast_to_uuid(value)&.to_s)
      end
    end
  end
end
