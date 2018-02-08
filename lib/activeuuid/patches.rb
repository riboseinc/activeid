require "active_record"
require "active_support/concern"

if (ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 2) ||
    (ActiveRecord::VERSION::MAJOR == 5)
  module ActiveRecord
    module Type
      class UUID < Binary # :nodoc:
        def type
          :uuid
        end

        def serialize(value)
          return if value.nil?
          UUIDTools::UUID.serialize(value)
        end

        def cast_value(value)
          UUIDTools::UUID.serialize(value)
        end

        def cast(value)
          cast_value value
        end
      end
    end
  end

  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQL
        module OID # :nodoc:
          class Uuid < Type::Value # :nodoc:
            def type_cast_from_user(value)
              UUIDTools::UUID.serialize(value) if value
            end
          end
        end
      end
    end
  end
end

module ActiveUUID
  module Patches
    module Migrations
      def uuid(*column_names)
        options = column_names.extract_options!
        column_names.each do |name|
          puts "what is ActiveRecord::Base.connection.adapter_name.downcase????"
          pp ActiveRecord::Base.connection.adapter_name.downcase
          type = ActiveRecord::Base.connection.adapter_name.casecmp("postgresql").zero? ? "uuid" : "binary(16)"
          puts "so migration type is #{type}"
          column(name, "#{type}#{' PRIMARY KEY' if options.delete(:primary_key)}", options)
        end
      end
    end

    module Column
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def type_cast(value)
          return UUIDTools::UUID.serialize(value) if type == :uuid
          super
        end

        def type_cast_code(var_name)
          return "UUIDTools::UUID.serialize(#{var_name})" if type == :uuid
          super
        end

        def simplified_type(field_type)
          return :uuid if field_type == "binary(16)" || field_type == "binary(16,0)"
          super
        end
      end
    end

    module MysqlJdbcColumn
      extend ActiveSupport::Concern

      included do
        # This is a really hacky solution, but it's the only way to support the
        # MySql JDBC adapter without breaking backwards compatibility.
        # It would be a lot easier if AR had support for custom defined types.
        #
        # Here's the path of execution:
        # (1) JdbcColumn calls ActiveRecord::ConnectionAdapters::Column super constructor
        # (2) super constructor calls simplified_type from MysqlJdbcColumn, since it's redefined here
        # (3) if it's not a uuid, it calls original_simplified_type from ArJdbc::MySQL::Column module
        # (4)   if there's no match ArJdbc::MySQL::Column calls super (ActiveUUID::Column.simplified_type_with_uuid)
        # (5)     Since it's no a uuid (see step 3), simplified_type_without_uuid is called,
        #         which maps to AR::ConnectionAdapters::Column.simplified_type (which has no super call, so we're good)
        #
        alias_method :original_simplified_type, :simplified_type

        def simplified_type(field_type)
          return :uuid if field_type == "binary(16)" || field_type == "binary(16,0)"
          original_simplified_type(field_type)
        end
      end
    end

    module PostgreSQLColumn
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def type_cast(value)
          return UUIDTools::UUID.serialize(value) if type == :uuid
          super
        end
        alias_method_chain :type_cast, :uuid if ActiveRecord::VERSION::MAJOR >= 4

        def simplified_type(field_type)
          return :uuid if field_type == "uuid"
          super
        end
      end
    end

    module Quoting
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def quote(value, column = nil)
          value = UUIDTools::UUID.serialize(value) if column&.type == :uuid
          case method(__method__).super_method.arity
          when 1 then super(value)
          else super
          end
        end

        def type_cast(value, column = nil)
          value = UUIDTools::UUID.serialize(value) if column&.type == :uuid
          super
        end

        def native_database_types
          super.merge(uuid: { name: "binary", limit: 16 })
        end
      end
    end

    module PostgreSQLQuoting
      extend ActiveSupport::Concern

      def self.prepended(_klass)
        def quote(value, column = nil)
          value = UUIDTools::UUID.serialize(value) if column&.type == :uuid
          value = value.to_s if value.is_a? UUIDTools::UUID
          case method(__method__).super_method.arity
          when 1 then super(value)
          else super
          end
        end

        def type_cast(value, column = nil, *args)
          value = UUIDTools::UUID.serialize(value) if column&.type == :uuid
          value = value.to_s if value.is_a? UUIDTools::UUID
          super
        end

        def native_database_types
          super.merge(uuid: { name: "uuid" })
        end
      end
    end

    module PostgresqlTypeOverride
      def deserialize(value)
        UUIDTools::UUID.serialize(value) if value
      end

      alias_method :cast, :deserialize
    end

    module TypeMapOverride
      def initialize_type_map(m)
        super

        register_class_with_limit m, /binary\(16(,0)?\)/i, ::ActiveRecord::Type::UUID
      end
    end

    module MysqlTypeToSqlOverride
      def type_to_sql(*args)
        args.first.to_s == "uuid" ? "binary(16)" : super
      end
    end

    module ConnectionHandling
      def establish_connection(_ = nil)
        super

        aca = ActiveRecord::ConnectionAdapters

        aca::Table.send           :include, Migrations if defined? aca::Table
        aca::TableDefinition.send :include, Migrations if defined? aca::TableDefinition

        if ActiveRecord::VERSION::MAJOR >= 5
          if defined? aca::AbstractMysqlAdapter
            aca::AbstractMysqlAdapter.prepend TypeMapOverride
            aca::AbstractMysqlAdapter.prepend MysqlTypeToSqlOverride
          end

          aca::SQLite3Adapter.prepend        TypeMapOverride        if defined? aca::SQLite3Adapter
          aca::PostgreSQL::OID::Uuid.prepend PostgresqlTypeOverride if defined? aca::PostgreSQLAdapter

        elsif ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 2
          aca::Mysql2Adapter.prepend  TypeMapOverride if defined? aca::Mysql2Adapter
          aca::SQLite3Adapter.prepend TypeMapOverride if defined? aca::SQLite3Adapter

        else
          aca::Column.send           :prepend, Column
          aca::PostgreSQLColumn.send :prepend, PostgreSQLColumn if defined? aca::PostgreSQLColumn
        end

        aca::MysqlAdapter.send      :prepend, Quoting           if defined? aca::MysqlAdapter
        aca::Mysql2Adapter.send     :prepend, Quoting           if defined? aca::Mysql2Adapter
        aca::SQLite3Adapter.send    :prepend, Quoting           if defined? aca::SQLite3Adapter
        aca::PostgreSQLAdapter.send :prepend, PostgreSQLQuoting if defined? aca::PostgreSQLAdapter
      end
    end

    def self.apply!
      ActiveRecord::Base.singleton_class.prepend ConnectionHandling
    end
  end
end
