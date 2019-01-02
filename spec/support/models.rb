class Article < ActiveRecord::Base
end

# Defines classes:
#
# - BinaryUuidArticle
# - BinaryUuidArticleWithNaturalKey
# - BinaryUuidArticleWithNamespace
# - StringUuidArticle
# - StringUuidArticleWithNaturalKey
# - StringUuidArticleWithNamespace
# - NativeUuidArticle
# - NativeUuidArticleWithNaturalKey
# - NativeUuidArticleWithNamespace
%w[binary string native].each do |table_prefix|
  table_name = "#{table_prefix}_uuid_articles"
  attribute_type_name = table_prefix == "binary" ? "BinaryUUID" : "StringUUID"
  attribute_type = ActiveUUID::AttributeType.const_get(attribute_type_name)

  regular_class = Class.new(ActiveRecord::Base) do
    include ActiveUUID::Model
    self.table_name = table_name
    attribute :id, attribute_type.new
    attribute :another_uuid, attribute_type.new
  end

  natural_key_class = Class.new(regular_class) do
    natural_key :title
  end

  key_with_namescape_class = Class.new(natural_key_class) do
    uuid_namespace "45e676ea-8a43-4ffe-98ca-c142b0062a83" # a random UUID
  end

  regular_class_name = "#{table_prefix.camelize}UuidArticle"
  Object.const_set regular_class_name, regular_class
  natural_key_class_name = "#{regular_class_name}WithNaturalKey"
  Object.const_set natural_key_class_name, natural_key_class
  key_with_namescape_class_name = "#{regular_class_name}WithNamespace"
  Object.const_set key_with_namescape_class_name, key_with_namescape_class
end
