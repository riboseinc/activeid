require "active_record"

module ActiveUUID
  # A data type to be used with ActiveRecord.
  #
  # See docs for +::ActiveRecord::Attributes::ClassMethods#attribute+ for usage.
  # See docs for +::ActiveRecord::Type::Value+ for meaning of overriden methods.
  #
  # The +#type+ method is defined in a parent class, and returns +:binary+.
  class AttributeType < ::ActiveRecord::Type::Binary
    undef type

    delegate :cast_to_uuid, to: ActiveUUID::Utils

    # Converts UUID or its string representation into a binary value (see
    # super).
    def serialize(value)
      super(cast_to_uuid(value)&.raw)
    end

    # Converts binary values into UUIDs.
    def deserialize(value)
      cast_to_uuid(super(value))
    end

    # Converts strings into UUIDs on user input assignment, called internally
    # from #cast.
    def cast_value(value)
      super(cast_to_uuid(value))
    end
  end
end
