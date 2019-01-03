ActiveRecord::Type.register(
  :uuid,
  ::ActiveUUID::Type::BinaryUUID,
  adapter: :mysql2,
)

ActiveRecord::Type.register(
  :uuid,
  ::ActiveUUID::Type::StringUUID,
  adapter: :postgresql,
  override: true,
)

ActiveRecord::Type.register(
  :uuid,
  ::ActiveUUID::Type::BinaryUUID,
  adapter: :sqlite,
)
