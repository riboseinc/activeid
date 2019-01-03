uuid_fab_prefixes = %i[binary string native]
uuid_fab_suffixes = [nil, :with_namespace, :with_natural_key]

fab_names = uuid_fab_prefixes.product(uuid_fab_suffixes).map do |p, s|
  [p, "uuid_article", s].compact.join("_").to_sym
end

fab_names.push(:article, :registered_uuid_type_article)

fab_names.each do |fab_name|
  Fabricator(fab_name) do
    title { Forgery::LoremIpsum.word }
    body { Forgery::LoremIpsum.sentence }
  end
end
