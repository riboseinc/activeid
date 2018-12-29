class Article < ActiveRecord::Base
end

class UuidArticle < ActiveRecord::Base
  include ActiveUUID::Model
  attribute :id, ActiveUUID::AttributeType.new
  attribute :another_uuid, ActiveUUID::AttributeType.new
end

class UuidArticleWithNaturalKey < UuidArticle
  natural_key :title
end

class UuidArticleWithNamespace < UuidArticleWithNaturalKey
  uuid_namespace "45e676ea-8a43-4ffe-98ca-c142b0062a83" # a random UUID
end
