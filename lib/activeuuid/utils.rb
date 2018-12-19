require "uuidtools"

module ActiveUUID
  # Variety of convenience functions.
  module Utils
    module_function

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

    def quote_as_binary(value)
      uuid = cast_to_uuid(value)
      uuid && ::ActiveRecord::Type::Binary::Data.new(uuid.raw)
    end

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
