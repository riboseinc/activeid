module ActiveUUID
  module UUID
    extend ActiveSupport::Concern

    included do
      class_attribute :_natural_key, instance_writer: false
      class_attribute :_uuid_namespace, instance_writer: false
      class_attribute :_uuid_generator, instance_writer: false
      self._uuid_generator = :random

      singleton_class.prepend Instantiation
      before_create :generate_uuids_if_needed
    end

    module ClassMethods
      def natural_key(*attributes)
        self._natural_key = attributes
      end

      def uuid_namespace(namespace)
        namespace = Utils.cast_to_uuid(namespace)
        self._uuid_namespace = namespace
      end

      def uuid_generator(generator_name)
        self._uuid_generator = generator_name
      end

      def uuids(*_attributes)
        ActiveSupport::Deprecation.warn <<-EOS
          ActiveUUID detects uuid columns independently.
          There is no more need to use uuid method.
        EOS
      end

      def uuid_columns
        @uuid_columns ||= columns.select { |c| c.type == :uuid }.map(&:name)
      end
    end

    module Instantiation
      def instantiate(record, _record_models = nil)
        uuid_columns.each do |uuid_column|
          record[uuid_column] = UUIDTools::UUID.serialize(record[uuid_column]).to_s if record[uuid_column]
        end

        super(record)
      end
    end

    def create_uuid
      if _natural_key
        # TODO if all the attributes return nil you might want to warn about this
        chained = _natural_key.map { |attribute| send(attribute) }.join("-")
        UUIDTools::UUID.sha1_create(_uuid_namespace || UUIDTools::UUID_OID_NAMESPACE, chained)
      else
        case _uuid_generator
        when :random
          UUIDTools::UUID.random_create
        when :time
          UUIDTools::UUID.timestamp_create
        end
      end
    end

    def generate_uuids_if_needed
      primary_key = self.class.primary_key
      primary_key_attribute_type = self.class.type_for_attribute(primary_key)
      if ::ActiveUUID::AttributeType === primary_key_attribute_type
        send("#{primary_key}=", create_uuid) unless send("#{primary_key}?")
      end
    end
  end
end
