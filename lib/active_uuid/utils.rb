require "uuidtools"

module ActiveUUID
  # Variety of convenience functions.
  module Utils
    module_function

    # Casts +value+ to +UUIDTools::UUID+.
    #
    # When an instance of +UUIDTools::UUID+ or +nil+ is given, then this method
    # returns that argument.  When a +String+ is given, then it is parsed,
    # and respective instance of UUIDTools::UUID is returned.
    #
    # A variety of string formats is recognized:
    #
    # - 36 characters long strings (hexadecimal number interpolated with dashes)
    # - 32 characters long strings (hexadecimal number without dashes)
    # - 16 bytes long strings (binary representation of UUID)
    #
    # @param value [UUIDTools::UUID, String, nil] value to be casted
    #   to +UUIDTools::UUID+.
    # @raise [ArgumentError] argument cannot be casted to UUIDTools::UUID.
    # @return [UUIDTools::UUID, nil] respective UUID instance or nil.
    def cast_to_uuid(value)
      case value
      when UUIDTools::UUID, nil
        value
      when String
        parse_uuid_string(value)
      else
        m = "UUID, String, or nil required, but '#{value.inspect}' was given"
        raise ArgumentError, m
      end
    end

    # Casts UUID to binary and quotes it, so that it can be used in SQL query
    # interpolation.
    #
    #   model.where("id = ?", ActiveUUID.quote_as_binary(some_uuid))
    #
    # This method is unable to determine the correct attribute type.
    # It always casts UUIDs to their binary form, which may be unwanted in some
    # contexts, i.e. in case of UUIDs which are meant to be serialized as
    # strings or as Postgres' native +UUID+ data type.  Due to this fact,
    # it is generally recommended to avoid SQL query interpolation if possible.
    #
    # @param value [UUIDTools::UUID, String, nil] UUID or its representation
    #   to be quoted.
    # @raise [ArgumentError] see cast_to_uuid.
    # @return [::ActiveRecord::Type::Binary::Data, nil] a binary value which
    #   can be used in SQL queries.
    def quote_as_binary(value)
      uuid = cast_to_uuid(value)
      uuid && ::ActiveRecord::Type::Binary::Data.new(uuid.raw)
    end

    # :nodoc:
    # Unfortunately, UUIDTools is missing some validations, hence we have to do
    # them here.
    #
    # TODO More validations, see specs.
    def self.parse_uuid_string(str)
      case str.size
      when 16 then uuid = UUIDTools::UUID.parse_raw(str)
      when 32 then uuid = UUIDTools::UUID.parse_hexdigest(str)
      when 36 then uuid = UUIDTools::UUID.parse(str)
      end
    ensure
      unless uuid # Guard for both exceptions and nil return values
        raise ArgumentError, "Expected string which is 16, 32, or 36 " +
          "characters long, and represents UUID, but #{str.inspect} was given"
      end
    end

    private_class_method :parse_uuid_string
  end
end
