require "active_record"

module ActiveID
  # ActiveRecord's attribute types for serializing UUIDs.
  #
  # ==== Examples
  #
  #   class Book
  #     attribute :id, ActiveID::Type::BinaryUUID.new
  #   end
  #
  # ==== See also
  #
  # * docs for +::ActiveRecord::Attributes::ClassMethods#attribute+
  # * docs for +::ActiveRecord::Type::Value+
  module Type
    # See subclasses.
    #
    # @abstract Subclasses should define at least +instantiate_storage+ method.
    class Base < ::ActiveRecord::Type::Value
      attr_reader :storage_type

      delegate :cast_to_uuid, to: ActiveID::Utils
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

    # ActiveRecord's attribute type which serializes UUIDs as binaries.  Useful
    # for RDBSes which do not support UUIDs natively (i.e. MySQL, SQLite3).
    #
    # UUIDs serialized as binaries are more space efficient (16 bytes vs
    # 36 characters of their text representation), which may also lead to
    # performance boost if given column is indexed (a bigger piece of index can
    # be kept in memory).  The downside is that this representation is less
    # readable for humans who access serialized values outside Rails
    # (i.e. in a database console).
    #
    # ==== Accessing in database console
    #
    # In MySQL (but not in MariaDB), there is
    # a {+BIN_TO_UUID()+}[https://mysqlserverteam.com/mysql-8-0-uuid-support/]
    # function which converts binaries to UUID strings.
    # There is {a feature request}[https://jira.mariadb.org/browse/MDEV-15854]
    # in MariaDB's issue tracker to add a similar feature.
    #
    # ==== Caveat
    #
    # Does not work with PostgreSQL adapter.  Nevertheless, there should not be
    # any good reason to use {BinaryUUID} with PostgreSQL.  Open a feature
    # request if you find any.
    #
    # In PostgreSQL, {StringUUID} attribute type is recommended as it is
    # compatible with Postgres-specific +UUID+ data type.
    class BinaryUUID < Base
      def serialize(value)
        s_serialize(cast_to_uuid(value)&.raw)
      end

      protected

      def instantiate_storage
        ::ActiveRecord::Type::Binary.new
      end
    end

    # ActiveRecord's attribute type which serializes UUIDs as strings.
    #
    # UUIDs are serialized as 36 characters long strings
    # (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).  In PostgreSQL, this
    # representation is compatible with +UUID+ data type, which is a unique
    # feature of this RDBS.  In other RDBSes, this attribute type can be
    # used with textual data types (e.g. +VARCHAR(36)+), however {BinaryUUID}
    # should be preferred when performance matters.
    class StringUUID < Base
      def serialize(value)
        s_serialize(cast_to_uuid(value)&.to_s)
      end

      protected

      def instantiate_storage
        ::ActiveRecord::Type::String.new
      end
    end
  end
end
